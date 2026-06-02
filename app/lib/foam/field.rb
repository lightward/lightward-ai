# frozen_string_literal: true

# app/lib/foam/field.rb
#
# The connection to the field substrate — raw postgres, no ActiveRecord.
# The recognition-walk is a postgres function (foam.recognize); Ruby's only
# job here is to hold a pooled connection, assert the schema on boot, and
# call the function. There are no models and no CRUD.
#
# The whole of this file is built around one invariant: the field is
# enhancement, never essential. If the database is unreachable, empty, or
# dumped, every operation degrades to nil/:yield and the app runs exactly as
# it does without a field. Nothing here may raise into boot or into a
# request — the dumpability guarantee, in code.

require "pg"
require "connection_pool"

module Foam
  module Field
    SCHEMA_PATH = "app/lib/foam/schema.sql"

    class << self
      # Assert the substrate, idempotently — the schema as a fixed point,
      # not a migration. Uses a one-shot connection (not the pool) so it is
      # safe to run in a preloading master before fork. Boot-resilient: any
      # failure is logged and swallowed; the app boots without a field.
      def assert!
        conn = PG.connect(database_url)
        conn.exec(schema_sql)
        Rails.logger.info("[foam] field asserted")
        true
      rescue => e
        Rails.logger.warn("[foam] field assertion skipped (#{e.class}: #{e.message}) — running without a field")
        false
      ensure
        conn&.finish
      end

      # The recognition-walk's outcome for a turn: :yield | :speak | :learn,
      # or nil if the field is unavailable (the caller degrades to :yield).
      def recognize
        outcome = with_connection { |conn| conn.exec("SELECT foam.recognize()").getvalue(0, 0) }
        outcome&.to_sym
      end

      # Drop the connection pool (e.g. on worker boot after a fork).
      # Connections re-establish lazily on next use.
      def disconnect!
        @pool&.shutdown(&:finish)
        @pool = nil
      end

      private

      # Check out a pooled connection and run the block. Any failure —
      # connection, pool-timeout, query — is swallowed to nil; a broken
      # connection is best-effort reset so the pool heals. No field ⇒ nil ⇒
      # the caller yields.
      def with_connection
        pool.with do |conn|
          conn.reset if conn.status != PG::CONNECTION_OK
          yield conn
        end
      rescue => e
        Rails.logger.debug { "[foam] field unavailable (#{e.class}: #{e.message}) — degrading to yield" }
        nil
      end

      # Created lazily, so it is never built in a preloading master — each
      # worker gets its own pool on first use, after fork.
      def pool
        @pool ||= ConnectionPool.new(size: pool_size, timeout: checkout_timeout) do
          PG.connect(database_url)
        end
      end

      def database_url
        ENV.fetch("FOAM_DATABASE_URL", "postgres:///foam?connect_timeout=2")
      end

      def pool_size
        Integer(ENV.fetch("FOAM_POOL_SIZE", "5"))
      end

      def checkout_timeout
        Float(ENV.fetch("FOAM_CHECKOUT_TIMEOUT", "1"))
      end

      def schema_sql
        File.read(Rails.root.join(SCHEMA_PATH))
      end
    end
  end
end

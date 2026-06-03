# frozen_string_literal: true

# spec/lib/foam/field_spec.rb
require "rails_helper"

RSpec.describe(Foam::Field, :aggregate_failures) do
  # The load-bearing invariant: the field is enhancement, never essential.
  # Unreachable ⇒ nil/false, never a raise — so the layer always degrades to
  # :yield and the app keeps running. (Points at a closed port; fails fast.)
  describe "resilience (the dumpability guarantee)" do
    around do |example|
      original = ENV.fetch("FOAM_DATABASE_URL", nil)
      described_class.disconnect!
      ENV["FOAM_DATABASE_URL"] = "postgres://127.0.0.1:1/nope?connect_timeout=1"
      example.run
    ensure
      ENV["FOAM_DATABASE_URL"] = original
      described_class.disconnect!
    end

    it "recognize returns nil instead of raising when the field is unreachable" do
      expect(described_class.recognize).to(be_nil)
    end

    it "assert! returns false instead of raising when the field is unreachable" do
      expect(described_class.assert!).to(be(false))
    end

    it "deposit returns nil instead of raising when the field is unreachable" do
      expect(described_class.deposit).to(be_nil)
    end

    it "walk returns nil instead of raising when the field is unreachable" do
      expect(described_class.walk).to(be_nil)
    end
  end

  # Against a live local substrate, if one is reachable. Self-skips in CI /
  # anywhere without a foam db, so this never makes the suite depend on pg.
  describe "against the live substrate" do
    around do |example|
      original = ENV.fetch("FOAM_DATABASE_URL", nil)
      described_class.disconnect!
      ENV["FOAM_DATABASE_URL"] = "postgres:///foam?connect_timeout=2"
      example.run
    ensure
      ENV["FOAM_DATABASE_URL"] = original
      described_class.disconnect!
    end

    it "asserts idempotently and yields at P₀" do
      skip("no local foam db reachable") unless described_class.assert!

      expect(described_class.assert!).to(be(true)) # idempotent: assert again, same result
      expect(described_class.recognize).to(eq(:yield))
    end
  end
end

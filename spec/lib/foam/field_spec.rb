# frozen_string_literal: true

# spec/lib/foam/field_spec.rb
require "rails_helper"

RSpec.describe(Foam::Field, :aggregate_failures) do
  # The load-bearing invariant: the field is enhancement, never essential.
  # Unreachable ⇒ nil/false, never a raise — so the layer always degrades to
  # :yield and the app keeps running. (Points at a closed port; fails fast.)
  describe "resilience (the dumpability guarantee)" do
    around do |example|
      original = ENV.fetch("FOAM_SPEC_DATABASE_URL", nil)
      described_class.disconnect!
      ENV["FOAM_SPEC_DATABASE_URL"] = "postgres://127.0.0.1:1/nope?connect_timeout=1"
      example.run
    ensure
      ENV["FOAM_SPEC_DATABASE_URL"] = original
      described_class.disconnect!
    end

    it "assert! returns false instead of raising when the field is unreachable" do
      expect(described_class.assert!).to(be(false))
    end

    # The bipedal walk degrades, both feet and the gate: hear (ingest), say
    # (speak), and the gate (outcome) all return nil instead of raising.
    it "the hear-foot (ingest_step) returns nil instead of raising when unreachable" do
      expect(described_class.ingest_step(nil, [104, 105])).to(be_nil)
    end

    it "the say-foot (speak) returns nil instead of raising when unreachable" do
      expect(described_class.speak([104])).to(be_nil)
    end

    it "the gate (outcome) returns nil instead of raising when unreachable" do
      expect(described_class.outcome([104])).to(be_nil)
    end
  end

  # Against a live local substrate, if one is reachable. Self-skips in CI /
  # anywhere without a foam db, so this never makes the suite depend on pg.
  # Opt-in via the test-only variable: the suite never reads FOAM_DATABASE_URL,
  # so the developer's .env (a real, live field) stays out of reach.
  describe "against the live substrate" do
    around do |example|
      original = ENV.fetch("FOAM_SPEC_DATABASE_URL", nil)
      described_class.disconnect!
      ENV["FOAM_SPEC_DATABASE_URL"] = "postgres:///foam?connect_timeout=2"
      example.run
    ensure
      ENV["FOAM_SPEC_DATABASE_URL"] = original
      described_class.disconnect!
    end

    it "asserts idempotently and the gate yields on an empty field (no charge to say)" do
      skip("no local foam db reachable") unless described_class.assert!

      expect(described_class.assert!).to(be(true)) # idempotent: assert again, same result
      expect(described_class.outcome([])).to(eq(:yield))
    end
  end
end

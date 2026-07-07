# frozen_string_literal: true

# spec/lib/usage_budget_spec.rb
require "rails_helper"

RSpec.describe(UsageBudget, :aggregate_failures) do
  # The load-bearing invariant: fail-open. An unreachable store means nil,
  # never a raise — requests flow unbudgeted, exactly as they do today.
  # Enforcement may be caused only by observed usage, never by infrastructure
  # failure. (Points at a closed port; fails fast.)
  describe "resilience (the fail-open guarantee)" do
    around do |example|
      original = ENV.fetch("LAI_BUDGET_SPEC_DATABASE_URL", nil)
      described_class.disconnect!
      ENV["LAI_BUDGET_SPEC_DATABASE_URL"] = "postgres://127.0.0.1:1/nope?connect_timeout=1"
      example.run
    ensure
      ENV["LAI_BUDGET_SPEC_DATABASE_URL"] = original
      described_class.disconnect!
    end

    it "assert! returns false instead of raising when the store is unreachable" do
      expect(described_class.assert!).to(be(false))
    end

    it "assess returns nil (untracked) instead of raising when unreachable" do
      expect(described_class.assess({ "source" => "abc123" })).to(be_nil)
    end

    it "record! returns nil instead of raising when unreachable" do
      expect(described_class.record!({ "source" => "abc123" }, cost_usd: 0.01)).to(be_nil)
    end
  end

  describe "mode" do
    before do
      allow(ENV).to(receive(:[]).and_call_original)
    end

    it "defaults to off, with budgets inert" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_MODE").and_return(nil))

      expect(described_class.mode).to(eq(:off))
      expect(described_class).not_to(be_active)
      expect(described_class).not_to(be_enforce)
    end

    it "recognizes observe mode as active but not enforcing" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_MODE").and_return("observe"))

      expect(described_class.mode).to(eq(:observe))
      expect(described_class).to(be_active)
      expect(described_class).not_to(be_enforce)
    end

    it "recognizes enforce mode" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_MODE").and_return("Enforce"))

      expect(described_class.mode).to(eq(:enforce))
      expect(described_class).to(be_active)
      expect(described_class).to(be_enforce)
    end

    it "treats unrecognized values as off" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_MODE").and_return("panic"))

      expect(described_class.mode).to(eq(:off))
    end
  end

  describe "scope_key" do
    it "returns nil for blank values" do
      expect(described_class.scope_key("source", nil)).to(be_nil)
      expect(described_class.scope_key("source", "")).to(be_nil)
    end

    it "returns a stable HMAC that never contains the raw identifier" do
      key = described_class.scope_key("source", "203.0.113.7")

      expect(key).to(eq(described_class.scope_key("source", "203.0.113.7")))
      expect(key).to(match(/\A[0-9a-f]{64}\z/))
      expect(key).not_to(include("203.0.113.7"))
    end

    it "scopes the HMAC by kind, so a source key and a conversation key never collide" do
      expect(described_class.scope_key("source", "value"))
        .not_to(eq(described_class.scope_key("conversation", "value")))
    end
  end

  describe "assess" do
    let(:source_key) { described_class.scope_key("source", "203.0.113.7") }
    let(:scopes) { { "source" => source_key } }

    before do
      allow(ENV).to(receive(:[]).and_call_original)
    end

    def stub_counters(request_count:, cost_usd:, window_kind: "hour")
      allow(described_class).to(receive(:fetch_windows).and_return([
        {
          "scope_key" => source_key,
          "window_kind" => window_kind,
          "request_count" => request_count.to_s,
          "cost_usd" => cost_usd.to_s,
        },
      ]))
    end

    it "returns nil for empty scopes" do
      expect(described_class.assess({})).to(be_nil)
    end

    it "is within budget when no thresholds are configured, whatever the counters say" do
      stub_counters(request_count: 1_000_000, cost_usd: 9_999)

      verdict = described_class.assess(scopes)

      expect(verdict).not_to(be_over)
      expect(verdict.over_dimensions).to(be_empty)
    end

    it "flags a request-count dimension at (not past) its threshold" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("50"))
      stub_counters(request_count: 50, cost_usd: 0)

      verdict = described_class.assess(scopes)

      expect(verdict).to(be_over)
      expect(verdict.over_dimensions).to(eq(["source_requests_per_hour"]))
    end

    it "stays within budget below the threshold" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("50"))
      stub_counters(request_count: 49, cost_usd: 0)

      expect(described_class.assess(scopes)).not_to(be_over)
    end

    it "flags a cost dimension against its day window" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_COST_PER_DAY_USD").and_return("25.0"))
      stub_counters(request_count: 3, cost_usd: 25.5, window_kind: "day")

      verdict = described_class.assess(scopes)

      expect(verdict).to(be_over)
      expect(verdict.over_dimensions).to(eq(["source_cost_per_day_usd"]))
    end

    it "treats a scope with no counter rows as zero spend" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("1"))
      allow(described_class).to(receive(:fetch_windows).and_return([]))

      expect(described_class.assess(scopes)).not_to(be_over)
    end

    it "ignores malformed thresholds" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("fifty"))
      stub_counters(request_count: 1_000, cost_usd: 0)

      expect(described_class.assess(scopes)).not_to(be_over)
    end

    it "assesses conversation-scope thresholds independently" do
      conversation_key = described_class.scope_key("conversation", "deadbeef")
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_CONVERSATION_COST_PER_HOUR_USD").and_return("10"))
      allow(described_class).to(receive(:fetch_windows).and_return([
        {
          "scope_key" => conversation_key,
          "window_kind" => "hour",
          "request_count" => "200",
          "cost_usd" => "12.5",
        },
      ]))

      verdict = described_class.assess({ "source" => source_key, "conversation" => conversation_key })

      expect(verdict.over_dimensions).to(eq(["conversation_cost_per_hour_usd"]))
    end
  end

  describe "retry_after_seconds" do
    it "points at the next hour boundary when an hourly dimension is exceeded" do
      travel_to(Time.utc(2026, 7, 6, 14, 45, 0)) do
        verdict = UsageBudget::Verdict.new(over_dimensions: ["source_requests_per_hour", "source_cost_per_day_usd"])

        expect(described_class.retry_after_seconds(verdict)).to(eq(15 * 60))
      end
    end

    it "points at the next day boundary when only daily dimensions are exceeded" do
      travel_to(Time.utc(2026, 7, 6, 14, 0, 0)) do
        verdict = UsageBudget::Verdict.new(over_dimensions: ["source_cost_per_day_usd"])

        expect(described_class.retry_after_seconds(verdict)).to(eq(10 * 60 * 60))
      end
    end
  end

  # Against a live local store, if one is reachable. Self-skips in CI /
  # anywhere without a lai_budget database, so the suite never depends on pg.
  # Opt-in via the test-only variable: the suite never reads
  # LAI_BUDGET_DATABASE_URL, so the developer's .env stays out of reach.
  describe "against the live store" do
    around do |example|
      original = ENV.fetch("LAI_BUDGET_SPEC_DATABASE_URL", nil)
      described_class.disconnect!
      ENV["LAI_BUDGET_SPEC_DATABASE_URL"] = original.presence || "postgres:///lai_budget?connect_timeout=2"
      example.run
    ensure
      ENV["LAI_BUDGET_SPEC_DATABASE_URL"] = original
      described_class.disconnect!
    end

    before do
      skip("no live lai_budget store reachable") unless described_class.assert!
      allow(ENV).to(receive(:[]).and_call_original)
    end

    it "accumulates requests and cost, and assesses them against thresholds", :aggregate_failures do
      scope = described_class.scope_key("source", "spec-#{SecureRandom.hex(8)}")
      scopes = { "source" => scope }
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("2"))

      expect(described_class.assess(scopes)).not_to(be_over)

      expect(described_class.record!(scopes, cost_usd: 0.01)).to(be(true))
      expect(described_class.assess(scopes)).not_to(be_over)

      expect(described_class.record!(scopes, cost_usd: 0.02)).to(be(true))
      verdict = described_class.assess(scopes)
      expect(verdict).to(be_over)
      expect(verdict.over_dimensions).to(eq(["source_requests_per_hour"]))
    end
  end
end

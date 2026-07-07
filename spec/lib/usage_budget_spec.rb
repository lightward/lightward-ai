# frozen_string_literal: true

# spec/lib/usage_budget_spec.rb
require "rails_helper"

RSpec.describe(UsageBudget, :aggregate_failures) do
  before do
    allow(ENV).to(receive(:[]).and_call_original)
  end

  after do
    described_class.disconnect!
  end

  def configure_store!(url)
    allow(ENV).to(receive(:[]).with("LAI_BUDGET_REDIS_URL").and_return(url))
  end

  # The load-bearing invariant: fail-open. An unconfigured or unreachable
  # store means nil, never a raise — requests flow unbudgeted, exactly as
  # they do today. Enforcement may be caused only by observed usage, never
  # by infrastructure failure. (Points at a closed port; fails fast.)
  describe "resilience (the fail-open guarantee)" do
    it "admit!, settle!, and refund! return nil when the store is unconfigured" do
      expect(described_class.admit!({ "source" => "abc123" })).to(be_nil)
      expect(described_class.settle!({ "source" => "abc123" }, cost_usd: 0.01)).to(be_nil)
      expect(described_class.refund!({ "source" => "abc123" })).to(be_nil)
    end

    it "returns nil instead of raising when the store is unreachable" do
      configure_store!("redis://127.0.0.1:1")

      expect(described_class.admit!({ "source" => "abc123" })).to(be_nil)
      expect(described_class.settle!({ "source" => "abc123" }, cost_usd: 0.01)).to(be_nil)
    end

    it "opens a breaker after a failure so the store is not re-dialed per request" do
      configure_store!("redis://127.0.0.1:1")

      expect(described_class.admit!({ "source" => "abc123" })).to(be_nil)
      expect(described_class.instance_variable_get(:@skip_until)).to(be_a(Time))

      allow(described_class).to(receive(:redis_client).and_call_original)
      expect(described_class.admit!({ "source" => "abc123" })).to(be_nil)
      expect(described_class).not_to(have_received(:redis_client))
    end

    it "disconnect! closes the breaker" do
      configure_store!("redis://127.0.0.1:1")
      described_class.admit!({ "source" => "abc123" })

      described_class.disconnect!

      expect(described_class.instance_variable_get(:@skip_until)).to(be_nil)
    end

    it "falls back to the default timeout on a malformed override" do
      allow(ENV).to(receive(:fetch).and_call_original)
      allow(ENV).to(receive(:fetch).with("LAI_BUDGET_TIMEOUT_SECONDS", "0.25").and_return("1s"))

      expect(described_class.send(:timeout_seconds)).to(eq(0.25))
    end
  end

  describe "mode" do
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
      at = Time.utc(2026, 7, 6, 12, 0, 0)
      key = described_class.scope_key("source", "203.0.113.7", at: at)

      expect(key).to(eq(described_class.scope_key("source", "203.0.113.7", at: at)))
      expect(key).to(match(/\A[0-9a-f]{64}\z/))
      expect(key).not_to(include("203.0.113.7"))
    end

    it "scopes the HMAC by kind, so a source key and a conversation key never collide" do
      expect(described_class.scope_key("source", "value"))
        .not_to(eq(described_class.scope_key("conversation", "value")))
    end

    it "rotates with the UTC day of `at`, so an actor is never linkable across days" do
      today = described_class.scope_key("source", "203.0.113.7", at: Time.utc(2026, 7, 6, 23, 59, 0))
      tomorrow = described_class.scope_key("source", "203.0.113.7", at: Time.utc(2026, 7, 7, 0, 1, 0))

      expect(today).not_to(eq(tomorrow))
    end
  end

  describe "admit!" do
    let(:source_key) { described_class.scope_key("source", "203.0.113.7") }
    let(:scopes) { { "source" => source_key } }

    # One [requests, cost] pair per scope per window in [hour, day] order,
    # followed by the MULTI's increment/expire results — the shape admit!'s
    # transaction returns. Values are pre-admission reads.
    def stub_counters(hour: [nil, nil], day: [nil, nil])
      allow(described_class).to(receive(:with_redis).and_return([hour, day, 1, true, 1, true]))
    end

    it "returns nil for empty scopes" do
      expect(described_class.admit!({})).to(be_nil)
    end

    it "returns nil (untracked) when the store yields nothing" do
      allow(described_class).to(receive(:with_redis).and_return(nil))

      expect(described_class.admit!(scopes)).to(be_nil)
    end

    it "is within budget when no thresholds are configured, whatever the counters say" do
      stub_counters(hour: ["1000000", "9999"], day: ["1000000", "9999"])

      verdict = described_class.admit!(scopes)

      expect(verdict).not_to(be_over)
      expect(verdict.over_dimensions).to(be_empty)
    end

    it "flags a request-count dimension at (not past) its threshold" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("50"))
      stub_counters(hour: ["50", "0"])

      verdict = described_class.admit!(scopes)

      expect(verdict).to(be_over)
      expect(verdict.over_dimensions).to(eq(["source_requests_per_hour"]))
    end

    it "stays within budget below the threshold" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("50"))
      stub_counters(hour: ["49", "0"])

      expect(described_class.admit!(scopes)).not_to(be_over)
    end

    it "flags a cost dimension against its day window" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_COST_PER_DAY_USD").and_return("25.0"))
      stub_counters(day: ["3", "25.5"])

      verdict = described_class.admit!(scopes)

      expect(verdict).to(be_over)
      expect(verdict.over_dimensions).to(eq(["source_cost_per_day_usd"]))
    end

    it "treats missing counters as zero spend" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("1"))
      stub_counters

      expect(described_class.admit!(scopes)).not_to(be_over)
    end

    it "ignores malformed thresholds" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("fifty"))
      stub_counters(hour: ["1000", "0"])

      expect(described_class.admit!(scopes)).not_to(be_over)
    end

    it "assesses conversation-scope thresholds independently" do
      conversation_key = described_class.scope_key("conversation", "deadbeef")
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_CONVERSATION_COST_PER_HOUR_USD").and_return("10"))
      allow(described_class).to(receive(:with_redis).and_return([
        [nil, nil],      # source hour
        [nil, nil],      # source day
        ["200", "12.5"], # conversation hour
        ["200", "12.5"], # conversation day
        1,
        true,
        1,
        true,
        1,
        true,
        1,
        true,
      ]))

      verdict = described_class.admit!({ "source" => source_key, "conversation" => conversation_key })

      expect(verdict.over_dimensions).to(eq(["conversation_cost_per_hour_usd"]))
    end

    it "in observe mode, an over verdict is returned without raising" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_MODE").and_return("observe"))
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("1"))
      stub_counters(hour: ["5", "0"])

      expect(described_class.admit!(scopes)).to(be_over)
    end

    it "in enforce mode, an over verdict refunds the admission and raises with the verdict attached" do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_MODE").and_return("enforce"))
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("1"))
      stub_counters(hour: ["5", "0"])
      allow(described_class).to(receive(:refund!))

      expect { described_class.admit!(scopes) }.to(raise_error(UsageBudget::Exceeded) { |error|
        expect(error.verdict).to(be_over)
        expect(error.verdict.over_dimensions).to(eq(["source_requests_per_hour"]))
      })
      expect(described_class).to(have_received(:refund!).with(scopes, at: kind_of(Time)))
    end
  end

  describe "settle!" do
    it "settles zero cost without touching the store" do
      allow(described_class).to(receive(:with_redis))

      expect(described_class.settle!({ "source" => "abc123" }, cost_usd: 0)).to(be(true))
      expect(described_class).not_to(have_received(:with_redis))
    end

    it "returns nil for empty scopes" do
      expect(described_class.settle!({}, cost_usd: 1.0)).to(be_nil)
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

  # Against a live local redis, if one is reachable (db 15, keys cleaned up).
  # Self-skips anywhere without one, so the suite never depends on redis.
  # Opt-in via the test-only variable: the suite never reads
  # LAI_BUDGET_REDIS_URL itself, so a developer's .env (a real, live store)
  # stays out of reach.
  describe "against the live store" do
    let(:live_url) { ENV.fetch("LAI_BUDGET_SPEC_REDIS_URL", "redis://127.0.0.1:6379/15") }
    let(:at) { Time.now.utc }
    let(:scope) { described_class.scope_key("source", "spec-#{SecureRandom.hex(8)}", at: at) }
    let(:scopes) { { "source" => scope } }

    before do
      begin
        Redis.new(url: live_url, timeout: 1).ping
      rescue StandardError
        skip("no live redis reachable at #{live_url}")
      end

      configure_store!(live_url)
    end

    after do
      client = Redis.new(url: live_url, timeout: 1)
      client.del(client.keys("#{UsageBudget::KEY_NAMESPACE}:#{scope}:*"))
      client.close
    rescue StandardError
      nil
    end

    it "admits, counts atomically, settles cost, and refunds — under TTL'd bucket keys", :aggregate_failures do
      allow(ENV).to(receive(:[]).with("LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR").and_return("2"))

      expect(described_class.admit!(scopes, at: at)).not_to(be_over)  # reads 0, counts to 1
      expect(described_class.admit!(scopes, at: at)).not_to(be_over)  # reads 1, counts to 2
      expect(described_class.admit!(scopes, at: at)).to(be_over)      # reads 2 >= 2 (observe: counted anyway)

      expect(described_class.settle!(scopes, cost_usd: 0.05, at: at)).to(be(true))

      client = Redis.new(url: live_url, timeout: 1)
      hour_key = "#{UsageBudget::KEY_NAMESPACE}:#{scope}:hour:#{at.strftime("%Y%m%d%H")}"
      expect(client.hget(hour_key, "requests")).to(eq("3"))
      expect(client.hget(hour_key, "cost").to_f).to(be_within(0.0001).of(0.05))
      expect(client.ttl(hour_key)).to(be_between(1, UsageBudget::TTL_SECONDS["hour"]))

      expect(described_class.refund!(scopes, at: at)).to(be(true))
      expect(client.hget(hour_key, "requests")).to(eq("2"))
      client.close
    end
  end
end

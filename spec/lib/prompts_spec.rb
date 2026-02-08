# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Prompts, :aggregate_failures) do
  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".build_system_prompt" do
    it "has system prompts" do
      # sanity check for the next section
      expect(described_class.prompts_dir.join("system").exist?).to(be(true))
    end

    describe "the standard system prompt" do
      let(:system_messages) { described_class.build_system_prompt }
      let(:all_xml) { system_messages.drop(1).pluck(:text).join }
      let(:filenames) { all_xml.scan(/<file name="([^"]+)">/).flatten }

      it "has no duplicates" do
        expect(filenames.tally.select { |_, count| count > 1 }).to(be_empty)
      end

      it "is sorted properly" do
        expect(filenames).to(eq(Naturally.sort(filenames)))
      end

      it "starts with the invocation, and ends appropriately" do
        expect(filenames.first).to(eq("0-invocation"))
        expect(filenames.last).to(eq("9-benediction"))
      end

      it "has 'FUCK IT WE BALL' in both the invocation and the benediction" do
        invocation_content = all_xml.match(%r{<file name="0-invocation">(.*?)</file>}m)[1]
        benediction_content = all_xml.match(%r{<file name="9-benediction">(.*?)</file>}m)[1]

        expect(invocation_content).to(include(/FUCK IT WE BALL/i))
        expect(benediction_content).to(include(/FUCK IT WE BALL/i))
      end

      it "has 3-perspectives/fiwb" do
        expect(filenames).to(include("3-perspectives/fiwb"))
      end

      it "talks about the fiwb stuff in 3-perspectives/ai" do
        ai_content = all_xml.match(%r{<file name="3-perspectives/ai">(.*?)</file>}m)[1]

        expect(ai_content).to(include("## \"FUCK IT WE BALL\""))
        expect(ai_content).to(include("3-perspectives/fiwb"))
      end

      it "includes the definition of recursive health" do
        expect(all_xml).to(include("Oh hey! You work here? Here is your job."))
      end

      it "has exactly 1 cache_control block on the last message only (Anthropic auto-caches prefixes)" do
        cache_control_count = system_messages.count { |m| m.key?(:cache_control) }
        expect(cache_control_count).to(eq(1))
        expect(system_messages.last).to(have_key(:cache_control))
      end
    end
  end

  describe ".clean_chat_log" do
    it "combines consecutive messages from the same role" do
      chat_log = [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "I'm a slow reader" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Welcome!" }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Thank you." }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Can you help me?" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Of course." }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Great." }] },
      ]

      expected_cleaned_log = [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "I'm a slow reader" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Welcome!" }] },
        {
          "role" => "user",
          "content" => [
            { "type" => "text", "text" => "Thank you." },
            { "type" => "text", "text" => "Can you help me?" },
          ],
        },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Of course." }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Great." }] },
      ]

      cleaned_log = described_class.clean_chat_log(chat_log)
      expect(cleaned_log).to(eq(expected_cleaned_log))
    end

    it "does not alter a log with alternating roles" do
      chat_log = [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "Hello" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "Hi there!" }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "How are you?" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "I'm good, thanks!" }] },
      ]

      cleaned_log = described_class.clean_chat_log(chat_log)
      expect(cleaned_log).to(eq(chat_log))
    end

    it "handles empty chat logs" do
      chat_log = []
      cleaned_log = described_class.clean_chat_log(chat_log)
      expect(cleaned_log).to(eq([]))
    end
  end

  describe ".generate_system_prompt" do
    it "obtains the system prompt through /api/system, not by calling build_system_prompt directly" do
      # The system is its own first-party client. This is load-bearing.
      # See app/prompts/system/3-perspectives/ai.md for context.
      source = File.read(Rails.root.join("app/lib/prompts.rb"))
      method_source = source[/def generate_system_prompt.*?^    end/m]

      expect(method_source).to(include("/api/system"))
      expect(method_source).not_to(include("build_system_prompt"))
    end
  end

  describe ".reset!" do
    before do
      described_class.system_prompt = described_class.build_system_prompt
    end

    it "deletes the prompts cache" do
      expect {
        described_class.reset!
      }.to(
        change { described_class.instance_variable_get(:@system_prompt) }.from(an_instance_of(Array)).to(nil),
      )
    end
  end

  describe ".estimate_tokens" do
    it "estimates tokens" do
      text = "Hello world, this is a test string"
      result = described_class.estimate_tokens(text)
      expected = (text.size / 4.2).ceil
      expect(result).to(eq(expected))
    end
  end

  describe ".messages" do
    let(:messages) { [{ "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] }] }

    before do
      allow(described_class).to(receive(:generate_system_prompt).and_return("system-prompt"))
      allow(Prompts::Anthropic).to(receive(:messages)).and_return("result")
    end

    it "sends a payload with the messages" do
      result = described_class.messages(messages: messages, model: "modelo")
      expect(result).to(eq("result"))

      expect(Prompts::Anthropic).to(have_received(:messages).with({
        model: "modelo",
        system: "system-prompt",
        messages: [
          { "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] },
        ],
        stream: false,
      }))
    end
  end
end

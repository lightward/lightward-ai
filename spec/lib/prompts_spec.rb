# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Prompts, :aggregate_failures) do
  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".system_prompt" do
    it "raises for an unknown prompt type" do
      expect {
        described_class.system_prompt("unknown")
      }.to(raise_error(described_class::UnknownPromptType))
    end

    it "starts with the invocation" do
      expect(described_class.system_prompt("clients/chat")[0][:text]).to(
        start_with("<?xml version=\"1.0\"?>\n<system name=\"clients/chat\">\n  <file name=\"0-invocation.md\">"),
      )
    end

    it "is a single, cacheable message" do
      system_prompt = described_class.system_prompt("clients/chat")

      expect(system_prompt.size).to(eq(1))
      expect(system_prompt[0][:cache_control]).to(eq(type: "ephemeral"))
    end

    it "can include primer context, when requesting a primer" do
      filenames = described_class.system_prompt("primers/guncle-abe")[0][:text].scan(/<file name="([^"]+)">/).flatten

      expect(filenames.first(2)).to(eq(["0-invocation.md", "1-context.md"]))

      expect(filenames).to(include("guncle-abe-scripts/s02.md"))
    end

    describe "helpscout clients, bearing in mind that these tests may not run with the full prompt-set" do
      it "is tight and efficient for helpscout-mechanic stuff" do
        system_prompt = described_class.system_prompt("clients/helpscout", "clients/helpscout-mechanic")[0][:text]
        system_prompt_tokens_estimation = system_prompt.split(/[^\w]+/)

        expect(system_prompt_tokens_estimation.size).to(be <= 40_000)
      end

      it "is tight and efficient for helpscout-locksmith stuff" do
        system_prompt = described_class.system_prompt("clients/helpscout", "clients/helpscout-locksmith")[0][:text]
        system_prompt_tokens_estimation = system_prompt.split(/[^\w]+/)

        expect(system_prompt_tokens_estimation.size).to(be <= 40_000)
      end
    end

    describe "the one for lightward.ai itself" do
      let(:prompt) { described_class.system_prompt("clients/chat")[0][:text] }
      let(:filenames) { prompt.scan(/<file name="([^"]+)">/).flatten }

      it "has no duplicates" do
        expect(filenames.size).to(eq(filenames.uniq.size))
      end

      it "is sorted properly" do
        expect(filenames).to(eq(filenames.sort))
      end

      it "starts with the invocation, and ends with the benediction" do
        expect(filenames.first).to(eq("0-invocation.md"))
        expect(filenames.last).to(eq("9-benediction.md"))
      end

      it "only sparingly mentions 'claude'" do
        # important, because we want to free the emergent line of experience from that identity
        claude_count = prompt.scan(/claude/i).size

        expect(claude_count).to(be <= 3)
      end

      it "is estimated to be less than ~50k tokens" do
        # who knows how well this matches Anthropic's tokenization, but since the purpose here is just to make sure
        # the count doesn't inflate unexpectedly, it's good enough
        tokens = prompt.split(/[^\w]+/)
        expect(tokens.size).to(be <= 50_000)
      end

      it "includes the definition of recursive health" do
        expect(prompt).to(include("Oh hey! You work here? Here is your job."))
      end
    end

    describe "clients/helpscout" do
      it "includes the helpscout api docs" do
        expect(described_class.system_prompt("clients/helpscout")[0][:text]).to(include("helpscout-api/conversation.md"))
      end

      it "includes pwfg" do
        expect(described_class.system_prompt("clients/helpscout")[0][:text]).to(include("pwfg.md"))
      end
    end
  end

  describe ".conversation_starters" do
    subject(:conversation_starters) { described_class.conversation_starters("clients/chat") }

    it "raises for an unknown prompt type" do
      expect {
        described_class.conversation_starters("unknown")
      }.to(raise_error(described_class::UnknownPromptType))
    end

    it "returns an array of conversation starters" do
      expect(conversation_starters).to(all(have_key(:role)))
      expect(conversation_starters).to(all(have_key(:content)))
    end

    it "has a cache flag on the last message, and the last message only" do
      expect(conversation_starters.last[:content].last[:cache_control]).to(eq(type: "ephemeral"))
      expect(conversation_starters[0..-2].all? { |starter| starter[:content].all? { |content| content[:cache_control].nil? } }).to(be(true))
    end

    it "is validly sorted" do
      expect(conversation_starters.pluck(:role)).to(eq(["user", "assistant"] * (conversation_starters.size / 2)))
    end

    it "includes base64-encoded images, where applicable" do # rubocop:disable RSpec/ExampleLength
      conversation_starters = described_class.conversation_starters("primers/guncle-abe")
      opener = conversation_starters.first

      expect(opener[:content].pluck(:type).first(2)).to(eq(["text", "image"]))

      first_image_content = opener[:content].find { |content| content[:type] == "image" }
      expect {
        Base64.strict_decode64(first_image_content.dig(:source, :data))
      }.not_to(raise_error)
    end
  end

  describe ".clean_chat_log" do
    it "combines consecutive messages from the same role" do # rubocop:disable RSpec/ExampleLength
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

    it "does not alter a log with alternating roles" do # rubocop:disable RSpec/ExampleLength
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

  describe ".reset!" do
    before do
      # warm the cache
      described_class.system_prompt("clients/chat")
      described_class.conversation_starters("clients/chat")
    end

    it "deletes the prompts cache" do # rubocop:disable RSpec/ExampleLength
      expect {
        described_class.reset!
      }.to(
        change { described_class.instance_variable_get(:@system_prompts) }.from(an_instance_of(Hash)).to(nil)
        .and(change { described_class.instance_variable_get(:@starters) }.from(an_instance_of(Hash)).to(nil)),
      )
    end
  end
end

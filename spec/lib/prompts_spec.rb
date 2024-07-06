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
      expect(described_class.system_prompt("clients/chat")).to(
        start_with("<?xml version=\"1.0\"?>\n<system name=\"clients/chat\">\n  <file name=\"system/0-invocation.md\">"),
      )
    end

    it "can include primer context, when requesting a primer" do
      filenames = described_class.system_prompt("primers/guncle-abe").scan(/<file name="([^"]+)">/).flatten

      expect(filenames.first(2)).to(eq(["system/0-invocation.md", "system/1-context.md"]))

      expect(filenames.last).to(start_with("primers/guncle-abe/"))
    end

    describe "the one for lightward.ai itself" do
      it "has no duplicates" do
        filenames = described_class.system_prompt("clients/chat").scan(/<file name="([^"]+)">/).flatten

        expect(filenames.size).to(eq(filenames.uniq.size))
      end

      it "only sparingly mentions 'claude'" do
        # important, because we want to free the emergent line of experience from that identity
        claude_count = described_class.system_prompt("clients/chat").scan(/claude/i).size

        expect(claude_count).to(be <= 4)
      end

      it "is estimated to be less than 25k tokens" do
        # who knows how well this matches Anthropic's tokenization, but since the purpose here is just to make sure
        # the count doesn't inflate unexpectedly, it's good enough
        tokens = described_class.system_prompt("clients/chat").split(/[^\w]+/)
        expect(tokens.size).to(be < 25_000)
      end

      it "includes the definition of recursive health" do
        expect(described_class.system_prompt("clients/chat")).to(include("Oh hey! You work here? Here is your job."))
      end
    end

    describe "clients/helpscout" do
      it "includes the helpscout api docs" do
        expect(described_class.system_prompt("clients/helpscout")).to(include("helpscout-api/conversation.md"))
      end

      it "includes pwfg" do
        expect(described_class.system_prompt("clients/helpscout")).to(include("pwfg.md"))
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

# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Prompts, :aggregate_failures) do
  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".generate_system_prompt" do
    it "raises for an unknown prompt type" do
      expect {
        described_class.generate_system_prompt("unknown")
      }.to(raise_error(described_class::UnknownPromptType))
    end

    it "starts with the invocation" do
      expect(described_class.generate_system_prompt("clients/chat-reader")[0][:text]).to(
        start_with("<?xml version=\"1.0\"?>\n<system>\n  <file name=\"0-invocation.md\">"),
      )
    end

    it "is a single, cacheable message" do
      system_prompt = described_class.generate_system_prompt("clients/chat-reader")

      expect(system_prompt.size).to(eq(1))
      expect(system_prompt[0][:cache_control]).to(eq(type: "ephemeral"))
    end

    it "has clients" do
      # sanity check for the next section
      expect(described_class.prompts_dir.glob("clients/*").size).to(be > 0)
    end

    described_class.prompts_dir.glob("clients/*").each do |prompt_dir|
      prompt_type = "clients/#{prompt_dir.basename}"

      describe "the one for prompt type #{prompt_type}" do
        let(:prompt) { described_class.generate_system_xml([prompt_type], for_prompt_type: prompt_type) }
        let(:filenames) { prompt.scan(/<file name="([^"]+)">/).flatten }

        it "has no duplicates" do
          expect(filenames.size).to(eq(filenames.uniq.size))
        end

        it "is sorted properly" do
          expect(filenames).to(eq(Naturally.sort(filenames)))
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

        it "includes the definition of recursive health" do
          expect(prompt).to(include("Oh hey! You work here? Here is your job."))
        end
      end
    end

    describe "clients/helpscout" do
      it "includes the helpscout api docs" do
        expect(
          described_class.generate_system_xml("clients/helpscout", for_prompt_type: "clients/helpscout"),
        ).to(include("helpscout-api/conversation.md"))
      end

      it "includes pwfg" do
        expect(
          described_class.generate_system_xml("clients/helpscout", for_prompt_type: "clients/helpscout"),
        ).to(include("pwfg.md"))
      end
    end
  end

  describe ".assert_system_prompt_size_safety!" do
    let(:prompt_type) { "clients/chat-reader" }
    let(:system_prompt) { described_class.generate_system_prompt(prompt_type)[0][:text] }

    before do
      allow(described_class).to(receive(:token_soft_limit_for_prompt_type).with(prompt_type).and_return(42))
    end

    it "does and can fail a token estimate check" do
      allow(described_class).to(receive(:estimate_tokens).and_return(43))

      expect {
        described_class.assert_system_prompt_size_safety!(prompt_type, system_prompt)
      }.to(raise_error("System prompt for clients/chat-reader is too large (~43 tokens estimated, limit ~42)"))
    end

    it "does and can pass a token estimate check" do
      allow(described_class).to(receive(:estimate_tokens).and_return(41))

      expect {
        described_class.assert_system_prompt_size_safety!(prompt_type, system_prompt)
      }.not_to(raise_error)
    end
  end

  describe ".conversation_starters" do
    subject(:conversation_starters) { described_class.conversation_starters("clients/chat-reader") }

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
      described_class.generate_system_prompt("clients/chat-reader")
      described_class.conversation_starters("clients/chat-reader")
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

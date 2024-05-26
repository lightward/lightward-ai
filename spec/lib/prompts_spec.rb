# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Prompts, :aggregate_failures) do
  describe ".anthropic_model" do
    it "reflects ANTHROPIC_MODEL" do
      ENV["ANTHROPIC_MODEL"] = "foo"
      expect(described_class.anthropic_model).to(eq("foo"))
    end

    it "can fall back to the default" do
      ENV.delete("ANTHROPIC_MODEL")
      expect(described_class.anthropic_model).to(eq(described_class.default_anthropic_model))

      ENV["ANTHROPIC_MODEL"] = ""
      expect(described_class.anthropic_model).to(eq(described_class.default_anthropic_model))
    end
  end

  describe ".default_anthropic_model" do
    it "has a default for dev vs prod" do
      ENV.delete("ANTHROPIC_MODEL")

      Rails.env = "development"
      expect(described_class.default_anthropic_model).to(eq("claude-3-haiku-20240307"))

      Rails.env = "production"
      expect(described_class.default_anthropic_model).to(eq("claude-3-opus-20240229"))
    end
  end

  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".system_prompt" do
    it "raises for an unknown prompt type" do
      expect {
        described_class.system_prompt("unknown")
      }.to(raise_error(Errno::ENOENT))
    end

    it "returns a string with system prompts" do
      expect(described_class.system_prompt("lightward")).to(include("Dear Claude,"))
    end

    it "starts with the invocation" do
      expect(described_class.system_prompt("lightward")).to(
        start_with("<?xml version=\"1.0\"?>\n<system>\n  <file name=\"system/0-invocation.md\">Dear Claude,"),
      )
    end

    it "can include primer context, when requesting a primer" do
      filenames = described_class.system_prompt("primers/guncle-abe").scan(/<file name="([^"]+)">/).flatten

      expect(filenames.first(2)).to(eq(["system/0-invocation.md", "system/1-context.md"]))

      expect(filenames.last).to(start_with("primers/guncle-abe/"))
    end
  end

  describe ".conversation_starters" do
    subject(:conversation_starters) { described_class.conversation_starters("lightward") }

    it "raises for an unknown prompt type" do
      expect {
        described_class.conversation_starters("unknown")
      }.to(raise_error(Errno::ENOENT))
    end

    it "returns an array of conversation starters" do
      expect(conversation_starters).to(all(have_key(:role)))
      expect(conversation_starters).to(all(have_key(:content)))
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
      described_class.system_prompt("lightward")
      described_class.conversation_starters("lightward")
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

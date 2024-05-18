# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Anthropic, :aggregate_failures) do
  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".system_prompt" do
    it "returns a string with system prompts" do
      expect(described_class.system_prompt).to(include("You are an AI representation of Lightward's philosophy."))
    end

    it "returns contents from naturally-sorted files" do
      sample_9 = described_class.prompts_dir.join("system", "9-pwfg-field-notes.md").read
      sample_10 = described_class.prompts_dir.join("system", "10-guncle-abe.md").read

      expect(described_class.system_prompt).to(include("#{sample_9}\n\n#{sample_10}"))
    end
  end

  describe ".conversation_starters" do
    it "returns an array of conversation starters" do
      expect(described_class.conversation_starters).to(all(have_key(:role)))
      expect(described_class.conversation_starters).to(all(have_key(:content)))
    end

    it "is validly sorted" do
      expect(described_class.conversation_starters.pluck(:role)).to(eq(["user", "assistant"] * (described_class.conversation_starters.size / 2)))
    end
  end
end

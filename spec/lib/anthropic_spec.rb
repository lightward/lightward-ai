# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Anthropic, :aggregate_failures) do
  describe ".model" do
    it "reflects ANTHROPIC_MODEL" do
      ENV["ANTHROPIC_MODEL"] = "foo"
      expect(described_class.model).to(eq("foo"))
    end

    it "can fall back to the default" do
      ENV.delete("ANTHROPIC_MODEL")
      expect(described_class.model).to(eq(described_class.default_model))

      ENV["ANTHROPIC_MODEL"] = ""
      expect(described_class.model).to(eq(described_class.default_model))
    end
  end

  describe ".default_model" do
    it "has a default for dev vs prod" do
      ENV.delete("ANTHROPIC_MODEL")

      Rails.env = "development"
      expect(described_class.default_model).to(eq("claude-3-haiku-20240307"))

      Rails.env = "production"
      expect(described_class.default_model).to(eq("claude-3-opus-20240229"))
    end
  end

  describe ".prompts_dir" do
    it "returns a directory that exists and has markdown files" do
      expect(Dir.exist?(described_class.prompts_dir)).to(be(true))
    end
  end

  describe ".system_prompt" do
    it "returns a string with system prompts" do
      expect(described_class.system_prompt).to(include("You are an AI representation of Lightward's philosophy."))
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

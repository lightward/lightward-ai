# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(Prompts::Anthropic, :aggregate_failures) do
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
end

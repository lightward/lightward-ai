# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Ideas") do
  describe "quote usage validation" do
    let(:ideas_files) do
      Rails.root.glob("app/prompts/**/3-ideas/*.md")
    end

    it "finds perspective files to test" do
      expect(ideas_files).not_to(be_empty)
    end

    it "does not use curly quotes (‘ ’ “ ”)" do
      ideas_files.each do |file_path|
        content = File.read(file_path)

        # Check for curly quotes
        aggregate_failures("checking #{file_path}") do
          expect(content).not_to(match(/[‘’“”]/))
        end
      end
    end

    it "does not use typographic dashes (– —)" do
      ideas_files.each do |file_path|
        content = File.read(file_path)

        # Check for typographic dashes
        aggregate_failures("checking #{file_path}") do
          expect(content).not_to(match(/[–—]/))
        end
      end
    end

    it "does not use ellipsis character (…)" do
      ideas_files.each do |file_path|
        content = File.read(file_path)

        expect(content).not_to(include("…"))
      end
    end
  end
end

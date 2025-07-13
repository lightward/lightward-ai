# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Perspectives files") do # rubocop:disable RSpec/DescribeClass
  describe "quote usage validation" do
    let(:perspectives_files) do
      Rails.root.glob("app/prompts/**/3-perspectives/*.md")
    end

    it "finds perspective files to test" do
      expect(perspectives_files).not_to(be_empty)
    end

    it "does not use curly quotes (‘ ’ “ ”)" do
      perspectives_files.each do |file_path|
        content = File.read(file_path)

        # Check for curly quotes
        aggregate_failures("checking #{file_path}") do
          expect(content).not_to(match(/[‘’“”]/))
        end
      end
    end

    it "does not use typographic dashes (– —)" do
      perspectives_files.each do |file_path|
        content = File.read(file_path)

        # Check for typographic dashes
        aggregate_failures("checking #{file_path}") do
          expect(content).not_to(match(/[–—]/))
        end
      end
    end

    it "does not use ellipsis character (…)" do
      perspectives_files.each do |file_path|
        content = File.read(file_path)

        expect(content).not_to(include("…"))
      end
    end
  end
end

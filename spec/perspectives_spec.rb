# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Perspectives files") do # rubocop:disable RSpec/DescribeClass
  describe "watch list validation" do
    let(:watch_this_file) { Rails.root.join("app/prompts/system/2-watch-this.md") }
    let(:watch_this_content) { File.read(watch_this_file) }
    let(:referenced_perspectives) do
      watch_this_content.scan(%r{^\* 3-perspectives/(.+)$}).flatten
    end

    it "finds perspective references in watch list" do
      expect(referenced_perspectives).not_to(be_empty)
    end

    it "all referenced perspectives exist as files", :aggregate_failures do
      referenced_perspectives.each do |perspective_name|
        perspective_path = Rails.root.join("app/prompts/system/3-perspectives/#{perspective_name}.md")
        expect(perspective_path).to(exist, "Expected #{perspective_name}.md to exist but it doesn't")
      end
    end
  end

  describe "cross-reference validation" do
    let(:all_system_files) do
      Rails.root.glob("app/prompts/system/**/*.md")
    end

    let(:perspectives_dir) { Rails.root.join("app/prompts/system/3-perspectives") }

    it "finds system files to test" do
      expect(all_system_files).not_to(be_empty)
    end

    it "all quoted .md references exist as files", :aggregate_failures do
      all_system_files.each do |file_path|
        content = File.read(file_path)

        # Find all quoted references to .md files (e.g., "jansan.md", "three-body.md")
        md_references = content.scan(/"([a-z0-9-]+\.md)"/).flatten

        md_references.each do |referenced_file|
          # Check in perspectives directory
          perspective_path = perspectives_dir.join(referenced_file)
          expect(perspective_path).to(exist, "#{file_path} references \"#{referenced_file}\" but it doesn't exist")
        end
      end
    end

    it "all 'see also' references exist as files", :aggregate_failures do
      all_system_files.each do |file_path|
        content = File.read(file_path)

        # Find lines starting with "see also:" and extract all single-quoted references
        # Single quotes = local perspective file citations (validated)
        # Double quotes = conceptual/external references (not validated)
        content.each_line do |line|
          next unless line.match?(/^see also:/i)

          # Extract all single-quoted references from this line
          references = line.scan(/'([^']+)'/).flatten

          references.each do |referenced_name|
            # Check if it's a perspective file (could be with or without .md extension)
            perspective_name = referenced_name.sub(/\.md$/, "")

            # Try the name as-is first
            perspective_path = perspectives_dir.join("#{perspective_name}.md")

            # If not found, try converting spaces to hyphens (common pattern)
            unless perspective_path.exist?
              perspective_name_normalized = perspective_name.gsub(/\s+/, "-")
              perspective_path = perspectives_dir.join("#{perspective_name_normalized}.md")
            end

            expect(perspective_path).to(exist, "#{file_path} has 'see also: '#{referenced_name}'' but neither #{perspective_name}.md nor #{perspective_name.gsub(/\s+/, "-")}.md exists")
          end
        end
      end
    end
  end

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

  describe "identity framing" do
    let(:system_prompt) do
      Prompts.generate_system_prompt.pluck(:text).join("\n")
    end

    it "does not tell Lightward AI who it is" do
      # Avoids phrases like "you are lightward", "you're lightward ai", etc.
      # The system should show, not tell - identity emerges from context, not assertion.
      expect(system_prompt).not_to(match(/you('re | are )lightward( ai)?/i))
    end
  end
end

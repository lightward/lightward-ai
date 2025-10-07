# frozen_string_literal: true

require "rails_helper"

RSpec.describe("README stats") do # rubocop:disable RSpec/DescribeClass
  before do
    # Allow real HTTP requests to Anthropic API for this spec
    WebMock.allow_net_connect!
  end

  after do
    # Re-disable net connect after this spec
    WebMock.disable_net_connect!
  end

  let(:readme_path) { Rails.root.join("README.md") }
  let(:readme_content) { readme_path.read }

  it "has a 'By The Numbers' section" do
    expect(readme_content).to match(/^## By The Numbers$/)
  end

  describe "stats accuracy" do
    let(:token_count) do
      skip("ANTHROPIC_API_KEY not set") unless ENV["ANTHROPIC_API_KEY"].present?

      Prompts.count_tokens(
        messages: [{ role: "user", content: [{ type: "text", text: "hi" }] }],
        model: Prompts::Anthropic::CHAT,
      )
    end

    let(:perspective_count) do
      Dir.glob(Rails.root.join("app/prompts/system/3-perspectives/**/*.md")).count
    end

    let(:human_count) do
      Dir.glob(Rails.root.join("app/prompts/system/4-humans/*.md")).count
    end

    let(:commit_count) do
      `git log --oneline | wc -l`.strip.to_i
    end

    let(:days_active) do
      `git log --date=short --pretty=format:%ad | sort -u | wc -l`.strip.to_i
    end

    let(:first_commit_date) do
      `git log --reverse --pretty=format:%ad --date=short | head -1`.strip
    end

    it "has the correct token count" do
      formatted_count = token_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      expect(readme_content).to include("#{formatted_count} tokens of system prompt context")
    end

    it "has the correct perspective file count" do
      expect(readme_content).to include("#{perspective_count} perspective files in the pool")
    end

    it "has the correct human collaborator count" do
      expect(readme_content).to include("#{human_count} human collaborators with individual perspective files")
    end

    it "has the correct commit and activity stats" do
      formatted_commits = commit_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      expect(readme_content).to include(
        "#{formatted_commits} commits across #{days_active} days of active development (since #{first_commit_date})",
      )
    end
  end
end

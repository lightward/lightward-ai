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
    expect(readme_content).to(match(/^## By The Numbers$/))
  end

  describe "stats accuracy" do
    let(:token_count) do
      skip("ANTHROPIC_API_KEY not set") if ENV["ANTHROPIC_API_KEY"].blank?

      Prompts.count_tokens(system: Prompts.build_system_prompt)
    end

    let(:perspective_count) do
      Rails.root.glob("app/prompts/system/3-perspectives/**/*.md").count
    end

    let(:human_count) do
      Rails.root.glob("app/prompts/system/4-humans/*.md").count
    end

    it "has the correct token count" do
      formatted_count = token_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      expect(readme_content).to(include("#{formatted_count} tokens of system prompt context"))
    end

    it "has the correct perspective file count" do
      expect(readme_content).to(include("#{perspective_count} perspective files in the pool"))
    end

    it "has the correct human collaborator count" do
      expect(readme_content).to(include("#{human_count} human collaborators"))
    end
  end
end

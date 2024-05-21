# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe(Prompts::WithContent, :aggregate_failures) do
  let(:uri_requested) { "http://example.com/resource" }
  let(:with_content_key) { described_class.calculate_with_content_key(uri_requested) }
  let(:response_body) { '<html><body><h1>Title</h1><script>alert("Hi");</script></body></html>' }
  let(:sanitized_body) { "<h1>Title</h1>" }
  let(:response) do
    instance_double(
      HTTParty::Response,
      body: response_body,
      code: 200,
      headers: { "Content-Type" => "text/html" },
      request: instance_double(HTTParty::Request, last_uri: URI(uri_requested)),
    )
  end

  before do
    allow(HTTParty).to(receive(:get).with(uri_requested).and_return(response))
  end

  describe ".prepare_with_content" do
    it "fetches and sanitizes the content, then stores it in the cache" do
      allow(Rails.cache).to(receive(:fetch).with(with_content_key, expires_in: 10.minutes).and_call_original)

      described_class.prepare_with_content(uri_requested)

      expect(HTTParty).to(have_received(:get).with(uri_requested))
      expect(Rails.cache).to(have_received(:fetch).with(with_content_key, expires_in: 10.minutes))
    end

    it "returns the with_content_key" do
      result = described_class.prepare_with_content(uri_requested)
      expect(result).to(eq(with_content_key))
    end
  end

  describe ".get_with_content" do
    it "retrieves the content from the cache" do
      allow(Rails.cache).to(receive(:read).with(with_content_key).and_return("cached_content"))

      result = described_class.get_with_content(uri_requested)

      expect(Rails.cache).to(have_received(:read).with(with_content_key))
      expect(result).to(eq("cached_content"))
    end
  end

  describe ".get_with_content_by_key" do
    it "retrieves the content from the cache by key" do
      allow(Rails.cache).to(receive(:read).with(with_content_key).and_return("cached_content"))

      result = described_class.get_with_content_by_key(with_content_key)

      expect(Rails.cache).to(have_received(:read).with(with_content_key))
      expect(result).to(eq("cached_content"))
    end

    it "returns an error message if the content is not found" do
      allow(Rails.cache).to(receive(:read).with(with_content_key).and_return(nil))

      result = described_class.get_with_content_by_key(with_content_key)

      expect(result).to(eq({ error: "Additional context was requested, but was not found." }))
    end
  end

  describe ".calculate_with_content_key" do
    it "generates a SHA256 hexdigest key" do
      key = described_class.calculate_with_content_key(uri_requested)
      expect(key).to(eq(Digest::SHA256.hexdigest("#{uri_requested}?#{Rails.application.secret_key_base}")))
    end
  end
end

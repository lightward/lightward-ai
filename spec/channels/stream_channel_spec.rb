# frozen_string_literal: true

# spec/channels/stream_channel_spec.rb
require "rails_helper"

RSpec.describe(StreamChannel) do
  let(:stream_id) { "test-stream-id" }

  before do
    stub_connection
    allow(Rails.cache).to(receive(:write))
    allow(Rails.cache).to(receive(:delete))
  end

  describe "#subscribed" do
    it "subscribes to a stream", :aggregate_failures do
      subscribe(stream_id: stream_id)

      expect(subscription).to(be_confirmed)
      expect(subscription).to(have_stream_from("stream_channel_#{stream_id}"))
    end
  end

  describe "#ready" do
    it "writes to the Rails cache" do
      subscribe(stream_id: stream_id)

      perform :ready
      expect(Rails.cache).to(have_received(:write).with("stream_ready_#{stream_id}", true, expires_in: 5.minutes))
    end
  end

  describe "#unsubscribed" do
    it "deletes from the Rails cache" do
      subscribe(stream_id: stream_id)

      subscription.unsubscribed
      expect(Rails.cache).to(have_received(:delete).with("stream_ready_#{stream_id}"))
    end
  end
end

# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe(StreamMessagesJob) do
  include ActiveSupport::Testing::TimeHelpers

  let(:chat_log) { [{ role: "user", content: [{ type: "text", text: "Hello" }] }] }
  let(:stream_id) { "test_stream_id" }
  let(:stream_ready_key) { "stream_ready_#{stream_id}" }
  let(:job) { described_class.new }

  before do
    allow(Rails.cache).to(receive(:read).with(stream_ready_key).and_return(true))
    allow(ActionCable.server).to(receive(:broadcast))
  end

  describe "#perform" do
    context "when the stream is not ready" do
      before do
        allow(Kernel).to(receive(:sleep))
        allow(Rails.cache).to(receive(:read).with(stream_ready_key) {
          travel(1.second)
          false
        })
      end

      it "broadcasts an error and raises an exception", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        expect { job.perform(stream_id, chat_log) }.to(raise_error("Stream not ready in time"))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "error",
          data: { error: { message: "Stream not ready in time" } },
          sequence_number: 0,
        ))
      end
    end

    context "when API responds with a rate limit error" do
      let(:headers) do
        {
          "anthropic-ratelimit-requests-limit" => "100",
          "anthropic-ratelimit-requests-remaining" => "0",
          "anthropic-ratelimit-requests-reset" => 10.seconds.from_now.to_s,
          "anthropic-ratelimit-tokens-limit" => "1000",
          "anthropic-ratelimit-tokens-remaining" => "0",
          "anthropic-ratelimit-tokens-reset" => 10.seconds.from_now.to_s,
        }
      end

      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 429, body: "", headers: headers)
      end

      it "handles the rate limit error" do # rubocop:disable RSpec/ExampleLength
        freeze_time do
          job.perform(stream_id, chat_log)
          expect(ActionCable.server).to(have_received(:broadcast).with(
            "stream_channel_#{stream_id}",
            event: "error",
            data: { error: { message: a_string_matching(/Rate limit exceeded for .*s/) } },
            sequence_number: 0,
          ))
        end
      end
    end

    context "when API responds with a connection error" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_raise(IOError)
      end

      it "logs the stream closed message", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        logger = instance_spy(Logger)
        allow(Rails).to(receive(:logger).and_return(logger))

        job.perform(stream_id, chat_log)

        expect(logger).to(have_received(:info).with("Stream closed"))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "end",
          data: nil,
          sequence_number: 0,
        ))
      end
    end

    context "when API responds with an unknown message type" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "data: {}\nunknown: message\n")
      end

      it "logs a warning" do
        logger = instance_spy(Logger)
        allow(Rails).to(receive(:logger).and_return(logger))

        job.perform(stream_id, chat_log)

        expect(logger).to(have_received(:warn).with("Unknown line format: unknown: message"))
      end
    end

    context "when the stream is ready and the API request is successful" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "data: {\"message\": \"Hello, world!\"}\n")
      end

      it "processes the response and broadcasts the data", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        job.perform(stream_id, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "message",
          data: { "message" => "Hello, world!" },
          sequence_number: 0,
        ))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "end",
          data: nil,
          sequence_number: 1,
        ))
      end
    end

    context "when the response contains multiple lines of data" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "data: {\"message\": \"Hello\"}\ndata: {\"message\": \"World\"}\n")
      end

      it "processes each line and broadcasts the data", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        job.perform(stream_id, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "message",
          data: { "message" => "Hello" },
          sequence_number: 0,
        ))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "message",
          data: { "message" => "World" },
          sequence_number: 1,
        ))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "end",
          data: nil,
          sequence_number: 2,
        ))
      end
    end

    context "when the response contains valid data events" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "event: message\ndata: {\"text\": \"Hello\"}\n")
      end

      it "processes the data event and broadcasts it", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        job.perform(stream_id, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "message",
          data: { "text" => "Hello" },
          sequence_number: 0,
        ))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "end",
          data: nil,
          sequence_number: 1,
        ))
      end
    end
  end

  describe "#broadcast" do
    it "sends the correct message via ActionCable" do # rubocop:disable RSpec/ExampleLength
      job.send(:broadcast, stream_id, "test_event", { test: "data" })

      expect(ActionCable.server).to(have_received(:broadcast).with(
        "stream_channel_#{stream_id}",
        event: "test_event",
        data: { test: "data" },
        sequence_number: 0,
      ))
    end
  end
end

# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(StreamMessagesJob) do
  let(:chat_log) { [{ role: "user", content: [{ type: "text", text: "Hello" }] }] }
  let(:stream_id) { "test_stream_id" }
  let(:stream_ready_key) { "stream_ready_#{stream_id}" }
  let(:system_prompt) { "system prompt" }
  let(:conversation_starters) { [{ role: "assistant", content: [{ type: "text", text: "How can I help you?" }] }] }
  let(:payload) do
    {
      model: "claude-3-opus-20240229",
      max_tokens: 2000,
      stream: true,
      temperature: 0.7,
      system: system_prompt,
      messages: conversation_starters + chat_log,
    }
  end
  let(:http) { instance_double(Net::HTTP) }
  let(:request) { instance_double(Net::HTTP::Post) }
  let(:response) { instance_double(Net::HTTPResponse) }

  before do
    allow(Rails.root.join("app/prompts/chat/system.md")).to(receive(:read).and_return(system_prompt))
    allow(Dir).to(receive(:[]).and_return([]))
    allow(Rails.cache).to(receive(:read).with(stream_ready_key).and_return(true))
    allow(ActionCable.server).to(receive(:broadcast))
    allow(Net::HTTP).to(receive(:new).and_return(http))
    allow(Net::HTTP::Post).to(receive(:new).and_return(request))
    allow(http).to(receive(:use_ssl=))
    allow(request).to(receive(:body=))
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
        expect { described_class.new.perform(chat_log, stream_id) }.to(raise_error("Stream not ready in time"))
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
          "anthropic-ratelimit-requests-limit" => ["100"],
          "anthropic-ratelimit-requests-remaining" => ["0"],
          "anthropic-ratelimit-requests-reset" => [10.seconds.from_now.to_s],
          "anthropic-ratelimit-tokens-limit" => ["1000"],
          "anthropic-ratelimit-tokens-remaining" => ["0"],
          "anthropic-ratelimit-tokens-reset" => [10.seconds.from_now.to_s],
        }
      end

      before do
        allow(http).to(receive(:request).and_yield(response))
        allow(response).to(receive_messages(code: "429", body: "", to_hash: headers))
        headers.each_key do |key|
          allow(response).to(receive(:[]).with(key).and_return(headers[key].first))
        end
      end

      it "handles the rate limit error" do # rubocop:disable RSpec/ExampleLength
        freeze_time do
          described_class.new.perform(chat_log, stream_id)
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
        allow(http).to(receive(:request).and_raise(IOError))
      end

      it "logs the stream closed message", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        logger = instance_spy(Logger)
        allow(Rails).to(receive(:logger).and_return(logger))

        described_class.new.perform(chat_log, stream_id)

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
        allow(http).to(receive(:request).and_yield(response))
        allow(response).to(receive(:code).and_return("200"))
        allow(response).to(receive(:read_body).and_yield("data: {}\nunknown: message\n"))
      end

      it "logs a warning" do
        logger = instance_spy(Logger)
        allow(Rails).to(receive(:logger).and_return(logger))

        described_class.new.perform(chat_log, stream_id)

        expect(logger).to(have_received(:warn).with("Unknown line format: unknown: message"))
      end
    end
  end

  describe "#broadcast" do
    it "sends the correct message via ActionCable" do # rubocop:disable RSpec/ExampleLength
      job = described_class.new
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

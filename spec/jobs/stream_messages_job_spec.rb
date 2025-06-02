# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(StreamMessagesJob) do
  include ActiveSupport::Testing::TimeHelpers

  let(:chat_log) { [{ role: "user", content: [{ type: "text", text: "Hello" }] }] }
  let(:chat_client) { "reader" }
  let(:stream_id) { "test_stream_id" }
  let(:stream_ready_key) { "stream_ready_#{stream_id}" }
  let(:job) { described_class.new }

  before do
    allow(Rails.cache).to(receive(:read).with(stream_ready_key).and_return(true))
    allow(ActionCable.server).to(receive(:broadcast))
    allow(Kernel).to(receive(:sleep))
    allow(Rollbar).to(receive(:error))

    # Stub the count_tokens API call
    stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
      .to_return(status: 200, body: '{"input_tokens": 1000}', headers: { "Content-Type" => "application/json" })
  end

  describe "#perform" do
    it "does the reader thing" do
      allow(Prompts::Anthropic).to(receive(:process_messages))

      job.perform(stream_id, "reader", chat_log)

      expect(Prompts::Anthropic).to(have_received(:process_messages).with(
        chat_log,
        prompt_type: "clients/chat",
        stream: true,
        model: Prompts::Anthropic::CHAT,
      ))
    end

    it "does the writer thing" do
      allow(Prompts::Anthropic).to(receive(:process_messages))

      job.perform(stream_id, "writer", chat_log)

      expect(Prompts::Anthropic).to(have_received(:process_messages).with(
        chat_log,
        prompt_type: "clients/chat",
        stream: true,
        model: Prompts::Anthropic::CHAT,
      ))
    end

    context "when the stream is not ready" do
      before do
        allow(Rails.cache).to(receive(:read).with(stream_ready_key) {
          travel(1.second)
          false
        })
      end

      it "broadcasts an error and raises an exception", :aggregate_failures do
        expect { job.perform(stream_id, chat_client, chat_log) }.to(raise_error("Stream not ready in time"))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "error",
          data: { error: { message: "Stream not ready in time" } },
          sequence_number: 0,
        ))
      end
    end

    context "when conversation exceeds token limit" do
      before do
        # Stub count_tokens to return a value over the limit
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(status: 200, body: '{"input_tokens": 250000}', headers: { "Content-Type" => "application/json" })

        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "broadcasts an error and does not call the API", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "error",
          data: { error: { message: "Conversation horizon has arrived; please start over to continue. 🤲" } },
          sequence_number: 0,
        ))

        # Should not make the main API call
        expect(WebMock).not_to(have_requested(:post, "https://api.anthropic.com/v1/messages"))
      end

      it "reports it to rollbar" do
        job.perform(stream_id, chat_client, chat_log)

        expect(Rollbar).to(have_received(:error).with(
          "StreamMessagesJob: token limit exceeded",
          hash_including(
            stream_id: stream_id,
            actual_tokens: 250000,
            limit: 200000,
          ),
        ))
      end
    end

    context "when token counting API fails" do
      before do
        # Stub count_tokens to fail
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(status: 500, body: "Internal Server Error")

        # Stub the main API call
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "data: {\"message\": \"Hello, world!\"}\n")

        allow(Rails.logger).to(receive(:warn))
      end

      it "logs a warning when falling back to estimation" do
        job.perform(stream_id, chat_client, chat_log)

        expect(Rails.logger).to(have_received(:warn).with(/Token counting API failed, using estimation:/))
      end

      it "continues with main API call when estimation is under limit" do
        job.perform(stream_id, chat_client, chat_log)

        # Should still make the main API call since estimation is under limit
        expect(WebMock).to(have_requested(:post, "https://api.anthropic.com/v1/messages").at_least_once)
      end
    end

    context "when API responds with a rate limit error" do
      let(:headers) do
        {
          "retry-after" => 10.hours.in_seconds.to_s,
          "anthropic-ratelimit-tokens-limit" => "1000",
          "anthropic-ratelimit-tokens-remaining" => "0",
          "anthropic-ratelimit-tokens-reset" => 10.hours.from_now.to_s,
        }
      end

      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 429, body: "", headers: headers)

        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "handles the rate limit error" do
        freeze_time do
          job.perform(stream_id, chat_client, chat_log)
          expect(ActionCable.server).to(have_received(:broadcast).with(
            "stream_channel_#{stream_id}",
            event: "error",
            data: { error: { message: a_string_matching("~10 hours") } },
            sequence_number: 0,
          ))
        end
      end

      it "reports it to rollbar" do
        job.perform(stream_id, chat_client, chat_log)

        expect(Rollbar).to(have_received(:error).with(
          "StreamMessagesJob: rate limit exceeded",
          hash_including(
            stream_id: stream_id,
          ),
        ))
      end
    end

    context "when API responds with a connection error" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_raise(IOError)
      end

      it "logs the stream closed message", :aggregate_failures do
        logger = instance_spy(Logger)
        allow(Rails).to(receive(:logger).and_return(logger))

        job.perform(stream_id, chat_client, chat_log)

        expect(logger).to(have_received(:info).with("Stream closed: Exception from WebMock"))
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

        job.perform(stream_id, chat_client, chat_log)

        expect(logger).to(have_received(:warn).with("Unknown line format: unknown: message"))
      end
    end

    context "when the stream is ready and the API request is successful" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "data: {\"message\": \"Hello, world!\"}\n")
      end

      it "processes the response and broadcasts the data", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

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

      it "processes the API call successfully" do
        job.perform(stream_id, chat_client, chat_log)

        # Should complete without error (API call metrics removed)
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(event: "end"),
        ))
      end
    end

    context "when the response contains multiple lines of data" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 200, body: "data: {\"message\": \"Hello\"}\ndata: {\"message\": \"World\"}\n")
      end

      it "processes each line and broadcasts the data", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

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

      it "processes the data event and broadcasts it", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

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
    it "sends the correct message via ActionCable" do
      job.send(:broadcast, stream_id, "test_event", { test: "data" })

      expect(ActionCable.server).to(have_received(:broadcast).with(
        "stream_channel_#{stream_id}",
        event: "test_event",
        data: { test: "data" },
        sequence_number: 0,
      ))
    end
  end

  describe "#reset_prompts_in_development" do
    before do
      allow(Prompts::Anthropic).to(receive(:api_request))
      allow(Prompts).to(receive(:reset!))
      allow($stdout).to(receive(:puts))
    end

    context "when in development" do
      around do |example|
        Rails.env = "development"
        example.run
      ensure
        Rails.env = "test"
      end

      it "is called automatically before performing the job" do
        expect_any_instance_of(described_class).to(receive(:reset_prompts_in_development)) # rubocop:disable RSpec/AnyInstance
        described_class.new(stream_id, chat_client, chat_log).perform_now
      end

      it "resets prompts" do
        job.send(:reset_prompts_in_development)
        expect(Prompts).to(have_received(:reset!))
      end
    end

    it "is not called in other environments" do
      Rails.env = "test"
      job.send(:reset_prompts_in_development)
      expect(Prompts).not_to(have_received(:reset!))
    end
  end
end

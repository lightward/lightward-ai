# frozen_string_literal: true

# spec/jobs/stream_messages_job_spec.rb
require "rails_helper"

RSpec.describe(StreamMessagesJob) do
  include ActiveSupport::Testing::TimeHelpers

  # Test helper for simulating streaming responses
  def simulate_streaming_response(events)
    body = events.map { |event|
      case event[:type]
      when :message_start
        "event: message_start\ndata: #{event[:data].to_json}\n\n"
      when :content_block_delta
        "event: content_block_delta\ndata: #{event[:data].to_json}\n\n"
      when :content_block_stop
        "event: content_block_stop\ndata: {}\n\n"
      when :message_stop
        "event: message_stop\ndata: {}\n\n"
      else
        "data: #{event[:data].to_json}\n\n"
      end
    }.join

    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(status: 200, body: body)
  end

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
      allow(Prompts).to(receive(:messages))

      job.perform(stream_id, "reader", chat_log)

      expect(Prompts).to(have_received(:messages).with(
        messages: chat_log,
        prompt_type: "clients/chat",
        stream: true,
        model: Prompts::Anthropic::CHAT,
      ))
    end

    it "does the writer thing" do
      allow(Prompts).to(receive(:messages))

      job.perform(stream_id, "writer", chat_log)

      expect(Prompts).to(have_received(:messages).with(
        messages: chat_log,
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

      it "broadcasts an error and end message", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "error",
          data: { error: { message: "Stream not ready in time" } },
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
    end

    context "when token counting API fails" do
      before do
        # Stub count_tokens to fail
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(status: 500, body: "Internal Server Error")

        allow(Rollbar).to(receive(:error))
      end

      it "broadcasts an error and does not call the API", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "error",
          data: { error: { message: "An unexpected error occurred" } },
          sequence_number: 0,
        ))
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "end",
          data: nil,
          sequence_number: 1,
        ))

        # Should report the error to Rollbar
        expect(Rollbar).to(have_received(:error))

        # Should not make the main API call
        expect(WebMock).not_to(have_requested(:post, "https://api.anthropic.com/v1/messages"))
      end
    end

    context "when API responds with a connection error" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_raise(IOError)
      end

      it "broadcasts connection error and end message", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          event: "error",
          data: { error: { message: "Connection error" } },
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
      job.instance_variable_set(:@stream_id, stream_id)
      job.send(:broadcast, "test_event", { test: "data" })

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
      allow(Prompts).to(receive(:messages))
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

  describe "token horizon warnings" do
    context "when approaching token limit (90% usage)" do
      before do
        # Stub token counting to return 90% of limit (45,000 tokens)
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(45_000)

        simulate_streaming_response([
          { type: :message_start, data: { message: { usage: {} } } },
          { type: :content_block_delta, data: { delta: { text: "Some response text" } } },
          { type: :content_block_stop, data: {} },
        ])
      end

      it "broadcasts a warning about approaching token limit", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

        # Should broadcast the warning after content_block_stop
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: "\n\n⚠️\u00A0Lightward AI system notice: Memory space 90% utilized; conversation horizon approaching",
              ),
            ),
          ),
        ))
      end

      it "calculates the correct usage percentage" do
        # Test with 95% usage
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(47_500)

        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: "\n\n⚠️\u00A0Lightward AI system notice: Memory space 95% utilized; conversation horizon approaching",
              ),
            ),
          ),
        ))
      end
    end

    context "when below warning threshold" do
      before do
        # Stub token counting to return 80% of limit (40,000 tokens)
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(40_000)

        simulate_streaming_response([
          { type: :message_start, data: { message: { usage: {} } } },
          { type: :content_block_delta, data: { delta: { text: "Some response text" } } },
          { type: :content_block_stop, data: {} },
        ])
      end

      it "does not broadcast a warning" do
        job.perform(stream_id, chat_client, chat_log)

        # Should NOT broadcast any warning
        expect(ActionCable.server).not_to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: match(/Memory space.*utilized/),
              ),
            ),
          ),
        ))
      end
    end

    context "when warning has already been shown in conversation" do
      let(:chat_log) do
        [
          { role: "user", content: [{ type: "text", text: "Hello" }] },
          { role: "assistant", content: [{ type: "text", text: "Hi! Memory space 92% utilized; conversation horizon approaching" }] },
          { role: "user", content: [{ type: "text", text: "Another message" }] },
        ]
      end

      before do
        # Still at high usage
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(46_000)

        simulate_streaming_response([
          { type: :message_start, data: { message: { usage: {} } } },
          { type: :content_block_delta, data: { delta: { text: "Response" } } },
          { type: :content_block_stop, data: {} },
        ])
      end

      it "does not show the warning again" do
        job.perform(stream_id, chat_client, chat_log)

        # Should NOT broadcast the warning again
        expect(ActionCable.server).not_to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: match(/Memory space.*utilized/),
              ),
            ),
          ),
        ))
      end
    end

    context "when exactly at 90% threshold" do
      before do
        # Exactly 90% of limit (45,000 tokens)
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(45_000)

        simulate_streaming_response([
          { type: :message_start, data: { message: { usage: {} } } },
          { type: :content_block_delta, data: { delta: { text: "Response" } } },
          { type: :content_block_stop, data: {} },
        ])
      end

      it "shows the warning at exactly 90%" do
        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: "\n\n⚠️\u00A0Lightward AI system notice: Memory space 90% utilized; conversation horizon approaching",
              ),
            ),
          ),
        ))
      end
    end

    context "when at 99% usage" do
      before do
        # 99% of limit
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(49_500)

        simulate_streaming_response([
          { type: :message_start, data: { message: { usage: {} } } },
          { type: :content_block_delta, data: { delta: { text: "Response" } } },
          { type: :content_block_stop, data: {} },
        ])
      end

      it "shows warning with correct percentage" do
        job.perform(stream_id, chat_client, chat_log)

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: "\n\n⚠️\u00A0Lightward AI system notice: Memory space 99% utilized; conversation horizon approaching",
              ),
            ),
          ),
        ))
      end
    end

    context "with multiple content blocks" do
      before do
        allow(Prompts::Anthropic).to(receive(:count_tokens)).and_return(45_000)

        simulate_streaming_response([
          { type: :message_start, data: { message: { usage: {} } } },
          { type: :content_block_delta, data: { delta: { text: "First block" } } },
          { type: :content_block_stop, data: {} },
          { type: :content_block_delta, data: { delta: { text: "Second block" } } },
          { type: :content_block_stop, data: {} },
        ])
      end

      it "only shows warning after the first content_block_stop", :aggregate_failures do
        job.perform(stream_id, chat_client, chat_log)

        # The warning should only be broadcast once despite multiple content blocks
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(
            event: "content_block_delta",
            data: hash_including(
              delta: hash_including(
                text: "\n\n⚠️\u00A0Lightward AI system notice: Memory space 90% utilized; conversation horizon approaching",
              ),
            ),
          ),
        ).once)

        # Verify other expected broadcasts still happen
        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(event: "message_start"),
        ))

        expect(ActionCable.server).to(have_received(:broadcast).with(
          "stream_channel_#{stream_id}",
          hash_including(event: "content_block_stop"),
        ).twice) # Two content blocks means two stops
      end
    end
  end
end

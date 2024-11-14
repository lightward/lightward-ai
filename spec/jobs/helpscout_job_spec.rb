# frozen_string_literal: true

# spec/jobs/helpscout_job_spec.rb
require "rails_helper"

RSpec.describe(HelpscoutJob) do
  let(:event_data) { { "id" => "test_conversation_id" } }
  let(:helpscout_conversation) {
    full_convo = JSON.parse(Rails.root.join("spec/fixtures/helpscout_full_convo.json").read)
    { "id" => "test_conversation_id" }.reverse_merge(full_convo)
  }
  let(:job) { described_class.new }

  before do
    allow(Helpscout).to(receive(:fetch_conversation).and_return(helpscout_conversation))
    allow(Helpscout).to(receive(:create_note))
    allow(Helpscout).to(receive(:create_draft_reply))

    allow(Slack::Web::Client).to(receive(:new).and_return(
      instance_double(Slack::Web::Client, chat_postMessage: { "ts" => "123" }),
    ))
  end

  describe "#perform" do
    context "when the incoming conversation concludes with something from the ai agent" do
      before do
        fixture = Rails.root.join("spec/fixtures/helpscout_full_convo_ending_with_assistant.json").read
        allow(Helpscout).to(receive(:fetch_conversation).and_return(JSON.parse(fixture)))
      end

      it "does not send a response", :aggregate_failures do
        job.perform(event_data["id"])
        expect(Helpscout).not_to(have_received(:create_note))
        expect(Helpscout).not_to(have_received(:create_draft_reply))
      end
    end

    context "when the incoming conversation is closed" do
      before do
        fixture = Rails.root.join("spec/fixtures/helpscout_convo_closed.json").read
        allow(Helpscout).to(receive(:fetch_conversation).and_return(JSON.parse(fixture)))
      end

      it "does not send a response", :aggregate_failures do
        job.perform(event_data["id"])
        expect(Helpscout).not_to(have_received(:create_note))
        expect(Helpscout).not_to(have_received(:create_draft_reply))
      end
    end

    context "when response type is 'note'" do
      before do
        allow(job).to(receive(:get_anthropic_response_data).with(anything, prompt_type: "clients/helpscout", system_prompt_types: ["clients/helpscout", "lib/locksmith-docs"]).and_return({ "content" => [{ "type" => "text", "text" => "directive=note&status=closed\n\nThis is a note." }] }))
      end

      it "creates a note in Help Scout" do
        job.perform(event_data["id"])
        expect(Helpscout).to(have_received(:create_note).with("test_conversation_id", "This is a note.", status: "closed"))
      end
    end

    context "when response type is 'reply'" do
      before do
        allow(job).to(receive(:get_anthropic_response_data).with(anything, prompt_type: "clients/helpscout", system_prompt_types: ["clients/helpscout", "lib/locksmith-docs"]).and_return({ "content" => [{ "type" => "text", "text" => "directive=reply&status=open\n\nThis is a reply." }] }))
      end

      it "creates a draft reply in Help Scout" do
        job.perform(event_data["id"])
        expect(Helpscout).to(have_received(:create_draft_reply).with("test_conversation_id", "This is a reply.", status: "open", customer_id: helpscout_conversation["primaryCustomer"]["id"]))
      end
    end

    it "requires a directive" do
      allow(job).to(receive(:get_anthropic_response_data).with(anything, prompt_type: "clients/helpscout", system_prompt_types: ["clients/helpscout", "lib/locksmith-docs"]).and_return({ "content" => [{ "type" => "text", "text" => "asdf\n\n" }] }))
      expect { job.perform(event_data["id"]) }.to(raise_error("No directive found in response: asdf"))
    end

    it "requires a valid directive" do
      allow(job).to(receive(:get_anthropic_response_data).with(anything, prompt_type: "clients/helpscout", system_prompt_types: ["clients/helpscout", "lib/locksmith-docs"]).and_return({ "content" => [{ "type" => "text", "text" => "directive=asdf\n\n" }] }))
      expect { job.perform(event_data["id"]) }.to(raise_error("Unrecognized directive: asdf"))
    end
  end

  describe "#get_anthropic_response_data" do
    let(:response_body) { { "content" => [{ "text" => "reply\n\nThis is a reply." }] }.to_json }

    before do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 200, body: response_body)

      allow(Prompts::Anthropic).to(receive(:process_messages).and_call_original)
    end

    it "returns the response text from the Anthropic API" do
      response_data = job.get_anthropic_response_data([], prompt_type: "clients/helpscout")
      expect(response_data).to(eq(JSON.parse(response_body)))
    end

    it "uses the correct model and prompt type" do # rubocop:disable RSpec/ExampleLength
      job.get_anthropic_response_data([], prompt_type: "clients/helpscout")

      expect(Prompts::Anthropic).to(have_received(:process_messages).with(
        [],
        model: Prompts::Anthropic::MODEL,
        prompt_type: "clients/helpscout",
        system_prompt_types: ["clients/helpscout"],
      ))
    end

    it "can request additional system prompt dirs" do # rubocop:disable RSpec/ExampleLength
      job.get_anthropic_response_data(
        [],
        prompt_type: "clients/helpscout",
        system_prompt_types: ["clients/helpscout", "lib/locksmith-docs"],
      )

      expect(Prompts::Anthropic).to(have_received(:process_messages).with(
        [],
        model: Prompts::Anthropic::MODEL,
        prompt_type: "clients/helpscout",
        system_prompt_types: ["clients/helpscout", "lib/locksmith-docs"],
      ))
    end

    context "when the API request fails" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises an error" do
        expect { job.get_anthropic_response_data([], prompt_type: "clients/helpscout") }.to(
          raise_error("Anthropic API request failed: 500 Internal Server Error"),
        )
      end
    end
  end
end

# frozen_string_literal: true

# spec/jobs/helpscout_job_spec.rb
require "rails_helper"

RSpec.describe(HelpscoutJob) do
  let(:event_type) { "test_event_type" }
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
  end

  describe "#perform" do
    context "when response type is 'note'" do
      before do
        allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-triage", anything).and_return("directive=note&status=closed\n\nThis is a note."))
      end

      it "creates a note in Help Scout" do
        job.perform(event_type, event_data)
        expect(Helpscout).to(have_received(:create_note).with("test_conversation_id", "This is a note.", status: "closed"))
      end
    end

    context "when response type is 'reply'" do
      before do
        allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-triage", anything).and_return("directive=reply&status=open\n\nThis is a reply."))
      end

      it "creates a draft reply in Help Scout" do
        job.perform(event_type, event_data)
        expect(Helpscout).to(have_received(:create_draft_reply).with("test_conversation_id", "This is a reply.", status: "open", customer_id: helpscout_conversation["primaryCustomer"]["id"]))
      end
    end

    context "when response type is 'doctor-doctor' and a note is in order" do
      before do
        allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-triage", anything).and_return("directive=doctor-doctor\n\n"))
        allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-md", anything).and_return("directive=note&status=active\n\nThis is a note from MD."))
      end

      it "switches to the MD prompt set and creates a note in Help Scout" do
        job.perform(event_type, event_data)
        expect(Helpscout).to(have_received(:create_note).with("test_conversation_id", "This is a note from MD.", status: "active"))
      end
    end

    context "when response type is 'doctor-doctor' and a reply is in order" do
      before do
        allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-triage", anything).and_return("directive=doctor-doctor\n\n"))
        allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-md", anything).and_return("directive=reply&status=closed\n\nThis is a reply from MD."))
      end

      it "switches to the MD prompt set and creates a draft reply in Help Scout" do
        job.perform(event_type, event_data)
        expect(Helpscout).to(have_received(:create_draft_reply).with("test_conversation_id", "This is a reply from MD.", status: "closed", customer_id: helpscout_conversation["primaryCustomer"]["id"]))
      end
    end

    it "requires a directive" do
      allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-triage", anything).and_return("asdf\n\n"))
      expect { job.perform(event_type, event_data) }.to(raise_error("No directive found in response: asdf"))
    end

    it "requires a valid directive" do
      allow(job).to(receive(:get_anthropic_response_text).with("clients/helpscout-triage", anything).and_return("directive=asdf\n\n"))
      expect { job.perform(event_type, event_data) }.to(raise_error("Unrecognized directive: asdf"))
    end
  end

  describe "#get_anthropic_response_text" do
    let(:messages) { [{ role: "user", content: [{ type: "text", text: HelpscoutJob::TRIAGE_PROMPT }] }] }
    let(:response_body) { { "content" => [{ "text" => "reply\n\nThis is a reply." }] }.to_json }

    before do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(status: 200, body: response_body)
    end

    it "returns the response text from the Anthropic API" do
      response_text = job.get_anthropic_response_text("clients/helpscout-triage", messages)
      expect(response_text).to(eq("reply\n\nThis is a reply."))
    end

    context "when the API request fails" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises an error" do
        expect { job.get_anthropic_response_text("clients/helpscout-triage", messages) }.to(
          raise_error("Anthropic API request failed: 500 Internal Server Error"),
        )
      end
    end
  end
end

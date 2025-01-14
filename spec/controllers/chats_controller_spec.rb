# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ChatsController, :aggregate_failures) do
  describe "GET #reader" do
    it "returns a successful response" do
      get :reader
      expect(response).to(have_http_status(:success))
    end
  end

  describe "GET #writer" do
    it "returns a successful response" do
      get :writer
      expect(response).to(have_http_status(:success))
    end
  end

  describe "POST #message" do
    # By default, let's start with "I'm a slow reader" so it matches validate_opening_message!
    let(:first_message) { "I'm a slow reader" }

    let(:valid_chat_log) do
      [
        { role: "user", content: [{ type: "text", text: first_message }] },
        { role: "assistant", content: [{ type: "text", text: "Hi there!" }] },
        { role: "user", content: [{ type: "text", text: "wow!" }] },
      ]
    end

    let(:invalid_chat_log) { [{}] }

    before do
      allow(SecureRandom).to(receive(:uuid).and_return("test-uuid"))
      allow(StreamMessagesJob).to(receive(:perform_later))
    end

    it "enqueues the StreamMessagesJob and returns a stream_id", :aggregate_failures do
      post :message, params: { chat_log: valid_chat_log }

      expect(response).to(have_http_status(:ok))
      expect(JSON.parse(response.body)).to(eq("stream_id" => "test-uuid"))

      permitted_params = valid_chat_log.map { |entry|
        ActionController::Parameters.new(entry)
          .permit(:role, content: [:type, :text])
          .to_h
          .with_indifferent_access
      }

      expect(StreamMessagesJob).to(have_received(:perform_later)
        .with("test-uuid", "reader", array_including(permitted_params[0], permitted_params[1])))
    end

    context "when in reader mode" do
      let(:first_message) { "I'm a slow reader" }

      it "uses the reader client" do
        post :message, params: { chat_log: valid_chat_log }

        expect(StreamMessagesJob).to(have_received(:perform_later)
          .with("test-uuid", "reader", anything))
      end
    end

    context "when in writer mode" do
      # Use "I'm a slow writer" so it matches writer logic
      let(:first_message) { "I'm a slow writer" }

      context "when the user is active" do
        before do
          allow(controller).to(
            receive(:current_user).and_return(instance_double(User, active?: true, admin?: false)),
          )
        end

        it "uses the writer client" do
          post :message, params: { chat_log: valid_chat_log }
          expect(StreamMessagesJob).to(have_received(:perform_later)
            .with("test-uuid", "writer", anything))
        end
      end

      context "when the user is not active" do
        before do
          user_double = instance_double(User, active?: false, admin?: false)
          allow(controller).to(receive(:current_user).and_return(user_double))
        end

        it "returns an error" do
          post(:message, params: { chat_log: valid_chat_log })

          expect(response).to(have_http_status(:payment_required))
          expect(response.body).to(eq(
            "This area requires a Lightward Pro subscription! " \
              "Scroll up, and click on your email address to continue. :)",
          ))
        end
      end

      context "when the user is not logged in" do
        before do
          allow(controller).to(receive(:current_user).and_return(nil))
        end

        it "returns an error" do
          post(:message, params: { chat_log: valid_chat_log })

          expect(response).to(have_http_status(:unauthorized))
          expect(response.body).to(eq("You must be logged in to use Lightward Pro. :)"))
        end
      end
    end

    context "when the user's been messing around with the opening message" do
      let(:first_message) { "I'm a slow dancer" } # invalid, triggers BadRequest

      it "raises an error" do
        expect {
          post(:message, params: { chat_log: valid_chat_log })
        }.to(raise_error(ActionController::BadRequest))
      end
    end

    it "raises a parameter error if the payload is malformed" do
      expect {
        post(:message, params: { chat_log: invalid_chat_log })
      }.to(raise_error(ActionController::ParameterMissing))
    end

    # ---------------------------
    # Tests for conversation-limit logic (non-subscribers/non-admins)
    # ---------------------------
    context "conversation limit logic for non-subscribers/non-admins" do # rubocop:disable RSpec/ContextWording
      before do
        # user is not active nor admin
        user_double = instance_double(User, active?: false, admin?: false)
        allow(controller).to(receive(:current_user).and_return(user_double))
      end

      context "when the user sends too many messages (over 20)" do
        it "raises BadRequest with subscription suggestion" do
          # The first message must match validate_opening_message!
          over_limit_log = [
            { role: "user", content: [{ type: "text", text: "I'm a slow reader" }] },
          ] + Array.new(20) do |i|
            { role: "user", content: [{ type: "text", text: "Message #{i}" }] }
          end

          expect {
            post(:message, params: { chat_log: over_limit_log })
          }.to(raise_error(ActionController::BadRequest, /Exceeded max number of messages \(20\).*/))
        end
      end

      context "when the user is near the limit (15 messages)" do
        it "returns a warning in the response JSON" do
          # 1 valid opening + 14 more => total 15
          near_limit_log = [
            { role: "user", content: [{ type: "text", text: "I'm a slow reader" }] },
          ] + Array.new(14) do |i|
            { role: "user", content: [{ type: "text", text: "Message #{i}" }] }
          end

          post :message, params: { chat_log: near_limit_log }

          expect(response).to(have_http_status(:ok))
          body = JSON.parse(response.body)
          expect(body["stream_id"]).to(eq("test-uuid"))

          # Warning should exist:
          expect(body["warning"]).to(match(/Heads up: You have \d+ message\(s\) left/))
          expect(body["warning"]).to(include("Unlock longer conversation lengths"))
        end
      end

      context "when a user message exceeds 250 characters" do
        it "raises BadRequest with subscription suggestion" do
          # The first message must be valid, second is 251 chars
          long_text = "a" * 251
          too_long_log = [
            { role: "user", content: [{ type: "text", text: "I'm a slow reader" }] },
            { role: "user", content: [{ type: "text", text: long_text }] },
          ]

          expect {
            post(:message, params: { chat_log: too_long_log })
          }.to(raise_error(ActionController::BadRequest, /Message too long.*Unlock longer message lengths/))
        end
      end
    end

    context "when the user is an admin" do
      before do
        allow(controller).to(
          receive(:current_user).and_return(instance_double(User, active?: false, admin?: true)),
        )
      end

      it "does not enforce the conversation limit" do
        # The first message must be valid
        big_log = [
          { role: "user", content: [{ type: "text", text: "I'm a slow reader" }] },
        ] + Array.new(24) do |i|
          { role: "user", content: [{ type: "text", text: "Message #{i}" }] }
        end

        post :message, params: { chat_log: big_log }

        # Expect success - no error
        expect(response).to(have_http_status(:ok))

        # No warning since we skip the non-subscriber checks
        body = JSON.parse(response.body)
        expect(body["warning"]).to(be_nil)
      end
    end

    describe "permitted_chat_log_params" do
      before do
        allow(controller).to(receive(:permitted_chat_log_params).and_call_original)
      end

      it "permits valid parameters" do
        valid_params = {
          chat_log: [
            { role: "user", content: [{ type: "text", text: "I'm a slow reader" }] },
            { role: "assistant", content: [{ type: "text", text: "Hi there!" }] },
          ],
        }

        post :message, params: valid_params
        valid_params[:chat_log].map(&:with_indifferent_access)
        expect(controller).to(have_received(:permitted_chat_log_params))
      end

      it "raises an error for invalid parameters" do
        invalid_params = { chat_log: [{}] }

        expect {
          post(:message, params: invalid_params)
        }.to(raise_error(ActionController::ParameterMissing))
      end
    end
  end

  describe "chat_context helper method" do
    context "when using reader mode" do
      it "returns a hash with the correct default keys and values" do
        get :reader
        expect(assigns(:chat_context)).to(eq({ key: "reader", name: "Lightward" }))
      end
    end

    context "when using writer mode" do
      it "returns a hash with the correct default keys and values" do
        allow(controller).to(
          receive(:current_user).and_return(instance_double(User, active?: true)),
        )
        get :writer
        expect(assigns(:chat_context)).to(eq({ key: "writer", name: "Lightward Pro" }))
      end
    end
  end
end

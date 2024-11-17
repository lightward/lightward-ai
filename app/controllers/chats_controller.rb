# frozen_string_literal: true

class ChatsController < ApplicationController
  helper_method :chat_context

  def reader
    chat_context[:localstorage_chatlog_key] = "chatLogData"
    render("chat_reader")
  end

  def writer
    if current_user
      chat_context[:localstorage_chatlog_key] = "writer"
      render("chat_writer")
    else
      render("login")
    end
  end

  def message
    chat_log = permitted_chat_log_params.as_json
    stream_id = SecureRandom.uuid

    opening_message = chat_log.dig(0, "content", 0, "text")
    validate_opening_message!(opening_message)

    chat_client = case opening_message
    when "I'm a slow reader", "I'm a fast reader"
      "reader"
    when "I'm a slow writer", "I'm a fast writer"
      "writer"
    end

    if chat_client == "writer"
      if !current_user
        return render(
          plain: "You must be logged in to use Lightward Pro. :)",
          status: :unauthorized,
        )
      elsif !current_user.active?
        return render(
          plain: "This area requires a Lightward Pro subscription! " \
            "Scroll up, and click on your email address to continue. :)",
          status: :payment_required,
        )
      end
    end

    # Enqueue the background job
    StreamMessagesJob.perform_later(stream_id, chat_client, chat_log)

    render(json: { stream_id: stream_id })
  end

  private

  def validate_opening_message!(opening_message)
    unless opening_message.to_s.match(/\AI\'m a (slow|fast) (reader|writer)\z/)
      raise ActionController::BadRequest
    end
  end

  def chat_context
    @chat_context ||= {}
  end

  def permitted_chat_log_params
    params.require(:chat_log).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end

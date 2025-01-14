# frozen_string_literal: true

class ChatsController < ApplicationController
  helper_method :chat_context

  def reader
    chat_context[:key] = "reader"
    chat_context[:name] = "Lightward"
    render("chat_reader")
  end

  def writer
    if current_user
      chat_context[:key] = "writer"
      chat_context[:name] = "Lightward Pro"
      render("chat_writer")
    else
      render("login")
    end
  end

  def message
    # Fetch and validate the chat_log with our custom limits
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

    # Check subscription status if they're using the writer client
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

    # Return the stream_id and a warning (if any) in our JSON response
    render(json: { stream_id: stream_id, warning: @near_limit_warning }.compact)
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

  # ---------------------------------------------------------
  # Enforce:
  # - Max of ENV["MAX_MESSAGES"] (default 20) for non-subscribers/non-admins
  # - Max ENV["MAX_CHARS_PER_MESSAGE"] (default 250) for user messages
  # - Warn if message count >= ENV["NEAR_LIMIT_THRESHOLD"] (default 15)
  # ---------------------------------------------------------
  def permitted_chat_log_params
    raw_params = params.require(:chat_log).map { |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    }

    # If user is neither a subscriber nor an admin, enforce conversation limits
    unless current_user&.active? || current_user&.admin?
      max_messages            = ENV.fetch("MAX_MESSAGES", 20).to_i
      max_chars_per_message   = ENV.fetch("MAX_CHARS_PER_MESSAGE", 250).to_i
      near_limit_threshold    = ENV.fetch("NEAR_LIMIT_THRESHOLD", 15).to_i

      # 1) Enforce total message count
      if raw_params.size > max_messages
        raise ActionController::BadRequest,
          "Exceeded max number of messages (#{max_messages}). " \
            "Unlock longer conversation lengths with a Lightward Pro subscription. " \
            "Scroll up, and click on your email address to continue. :)"
      end

      # 2) Warn when near the max depth
      if raw_params.size >= near_limit_threshold
        @near_limit_warning = "Heads up: You have " \
          "#{max_messages - raw_params.size} message(s) left " \
          "before hitting the limit of #{max_messages}. " \
          "Unlock longer conversation lengths with a Lightward Pro subscription! " \
          "Scroll up, and click on your email address to continue. :)"
      end

      # 3) Enforce character limit for user messages
      raw_params.each do |entry|
        next unless entry[:role] == "user" # Only user messages

        text_content = entry.dig(:content, 0, :text).to_s
        next if text_content.length <= max_chars_per_message

        raise ActionController::BadRequest,
          "Message too long (max #{max_chars_per_message} chars). " \
            "Unlock longer message lengths with a Lightward Pro subscription! " \
            "Scroll up, and click on your email address to continue. :)"
      end
    end

    raw_params
  end
end

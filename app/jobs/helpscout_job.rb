# frozen_string_literal: true

# app/jobs/helpscout_job.rb
class HelpscoutJob < ApplicationJob
  queue_with_priority PRIORITY_HELPSCOUT

  MAILBOX_CLIENTS = {
    201764 => "clients/helpscout-locksmith",
    204960 => "clients/helpscout-mechanic",
  }

  def perform(event_type, event_data)
    helpscout_conversation = Helpscout.fetch_conversation(event_data["id"], with_threads: true)
    thread_count = helpscout_conversation.dig("_embedded", "threads").count
    mailbox_id = helpscout_conversation["mailboxId"]

    slack_message = slack_client.chat_postMessage(
      channel: "#ai-logs",
      text: <<~eod.squish,
        Received Help Scout conversation ##{helpscout_conversation["number"]} (#{thread_count}): "#{helpscout_conversation["subject"]}"
      eod
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: <<~eod.squish,
              Received Help Scout conversation <https://secure.helpscout.net/conversation/#{helpscout_conversation["id"]}|##{helpscout_conversation["number"]}> (#{thread_count}): "#{helpscout_conversation["subject"]}"
            eod
          },
        },
      ],
    )

    # prevent this routine from looping
    if Helpscout.conversation_concludes_with_assistant?(helpscout_conversation)
      slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.squish)
        Conversation concluded with an AI message; no response needed.
      eod

      return
    end

    # ignore if closed
    if helpscout_conversation["status"] == "closed"
      slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.squish)
        Conversation is closed; no response needed.
      eod

      return
    end

    messages = Prompts.conversation_starters("clients/helpscout")

    messages << {
      role: "user",
      content: [
        { type: "text", text: "event type: #{event_type}" },
        { type: "text", text: "event data: #{event_data.to_json}" },
        { type: "text", text: "conversation: #{helpscout_conversation.to_json}" },
        { type: "text", text: <<~eod.squish },
          That's everything! Handing it over to you to generate your contribution to the Help Scout conversation. :)
        eod
      ],
    }

    mailbox_client = MAILBOX_CLIENTS[mailbox_id]
    prompt_type = "clients/helpscout"
    system_prompt_types = ["clients/helpscout", mailbox_client]

    slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.squish)
      Sending context to #{[prompt_type, *system_prompt_types].uniq.join(", ")}...
    eod

    response = get_anthropic_response_text(
      messages,
      prompt_type: "clients/helpscout",
      system_prompt_types: ["clients/helpscout", mailbox_client],
    )

    slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.strip)
      Received response from clients/helpscout:

      > #{response.gsub("\n", "\n> ")}
    eod

    handle_response(
      response,
      event_type: event_type,
      helpscout_conversation: helpscout_conversation,
      messages: messages,
    )
  rescue => error
    slack_client.chat_postMessage(channel: "#ai-logs", text: <<~eod.squish, thread_ts: slack_message["ts"])
      Error processing Help Scout webhook for conversation #{event_data["id"]}: #{error.message}
    eod

    raise
  end

  def handle_response(response, event_type:, helpscout_conversation:, messages: [])
    response_params_querystring, response_body = response.split("\n\n", 2)
    response_params = CGI.parse(response_params_querystring)
    directive = response_params["directive"].first
    response_status = response_params["status"].first

    helpscout_conversation_id = helpscout_conversation["id"]

    if directive.nil?
      raise "No directive found in response: #{response}".strip
    end

    case directive
    when "noop"
      # cute
    when "update_status"
      Helpscout.update_status(
        helpscout_conversation_id,
        status: response_status,
      )
    when "note"
      Helpscout.create_note(
        helpscout_conversation_id,
        response_body,
        status: response_status,
      )
    when "reply"
      helpscout_primary_customer_id = helpscout_conversation.dig("primaryCustomer", "id")

      Helpscout.create_draft_reply(
        helpscout_conversation_id,
        response_body,
        status: response_status,
        customer_id: helpscout_primary_customer_id,
      )
    else
      raise "Unrecognized directive: #{directive}"
    end
  end

  def get_anthropic_response_text(messages, prompt_type:, system_prompt_types: [prompt_type])
    Prompts::Anthropic.process_messages(messages, prompt_type: prompt_type, system_prompt_types: system_prompt_types) do
      |_request, response|
      if response.code != "200"
        raise "Anthropic API request failed: #{response.code} #{response.body}"
      end

      response_data = JSON.parse(response.body)
      response_text = response_data["content"][0]["text"]

      response_text
    end
  end

  def slack_client
    @client ||= Slack::Web::Client.new
  end
end

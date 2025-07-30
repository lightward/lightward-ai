# frozen_string_literal: true

# app/jobs/helpscout_job.rb
class HelpscoutJob < ApplicationJob
  queue_with_priority PRIORITY_HELPSCOUT

  MAILBOX_LIBS = {
    201764 => "lib/locksmith",
    204960 => "lib/mechanic",
  }

  def perform(convo_id)
    helpscout_conversation = Helpscout.fetch_conversation(convo_id, with_threads: true)
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

    # ignore if closed or spam
    if ["closed", "spam"].include?(helpscout_conversation["status"])
      slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.squish)
        Conversation is #{helpscout_conversation["status"]}; no response needed.
      eod

      return
    end

    messages = []

    messages += Prompts.conversation_starters("clients/helpscout")

    # be selective about what we pass in to the ai
    helpscout_conversation_for_ai = Helpscout.render_conversation_for_ai(helpscout_conversation)

    messages << {
      role: "user",
      content: [
        { type: "text", text: "Here's the current JSON representation of the Help Scout conversation." },
        { type: "text", text: helpscout_conversation_for_ai.to_json },
        { type: "text", text: <<~eod.squish },
          Over to you! To generate your contribution to the Help Scout conversation. :) With earnest honesty, and
          proactive/collaborative curiosity, do exactly as you will. :)
        eod
      ],
    }

    mailbox_lib = MAILBOX_LIBS[mailbox_id]
    prompt_type = "clients/helpscout"
    system_prompt_types = ["clients/helpscout", mailbox_lib]

    slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.squish)
      Sending context to #{[prompt_type, *system_prompt_types].uniq.join(", ")}...
    eod

    response_data = get_anthropic_response_data(
      messages,
      prompt_type: prompt_type,
      system_prompt_types: system_prompt_types,
    )

    slack_client.chat_postMessage(channel: "#ai-logs", thread_ts: slack_message["ts"], text: <<~eod.strip)
      Received response from clients/helpscout:

      > #{response_data["content"][0]["text"].gsub("\n", "\n> ")}

      Anthropic API usage data:

      ```
      #{JSON.pretty_generate(response_data["usage"])}
      ```
    eod

    handle_response(
      response_data,
      helpscout_conversation: helpscout_conversation,
      messages: messages,
    )
  rescue => error
    slack_client.chat_postMessage(channel: "#ai-logs", text: <<~eod.squish, thread_ts: slack_message&.dig("ts"))
      Error processing Help Scout webhook for conversation #{convo_id}: #{error.message}
    eod

    raise
  end

  def handle_response(response_data, helpscout_conversation:, messages: [])
    response_text = response_data["content"][0]["text"]
    response_params_querystring, response_body = response_text.split("\n\n", 2)
    response_params = CGI.parse(response_params_querystring)
    directive = response_params["directive"].first
    response_status = response_params["status"].first

    helpscout_conversation_id = helpscout_conversation["id"]

    if directive.nil?
      raise "No directive found in response: #{response_text}".strip
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

  def get_anthropic_response_data(messages, prompt_type:, system_prompt_types: [prompt_type])
    Prompts::Anthropic.process_messages(
      messages,
      model: Prompts::Anthropic::HELPSCOUT,
      prompt_type: prompt_type,
      system_prompt_types: system_prompt_types,
    ) do |_request, response|
      if response.code != "200"
        raise "Anthropic API request failed: #{response.code} #{response.body}"
      end

      JSON.parse(response.body)
    end
  end

  def slack_client
    @client ||= Slack::Web::Client.new
  end
end

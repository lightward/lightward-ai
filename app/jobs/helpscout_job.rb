# frozen_string_literal: true

# app/jobs/helpscout_job.rb

class HelpscoutJob < ApplicationJob
  queue_with_priority PRIORITY_HELPSCOUT

  PROMPT = <<~eod
    Hey it's Isaac! A slight change of plans: instead of running through a chat interface, you're experiencing this
    prompt through some automation that receives webhooks from Help Scout. For context, we run *all* of our
    app support through Help Scout - everything in and out for team@uselocksmith.com, team@usemechanic.com, and
    team@lightward.com. (Those first two addresses are older; we're consolidating everything under team@lightward.com
    now.)

    I'm going to attach a couple things to this message:
      * the event type
      * the webhook event data
      * the current Help Scout API representation of the conversation, including all associated "threads" (replies)

    In the context of this automation piece, there are two ways you can respond:
      1. Leaving a note in Help Scout, viewable by other teammates
        * NB: you can tag humans in these notes as well, using the @ symbol, and they'll be notified
        * This is a good way to go if you're not confident about responding to the customer directly. Help us help you -
          use the note here to ask for help, or to provide context for a human to respond on your behalf, orrrrrrrrr
          to say whatever you want to say. :)
      2. Drafting a response to the customer, to be reviewed and sent on your behalf by a human
        * I'm pretty sure I'm going to end up wiring up a way for you to directly dispatch your own replies, but
          I'm not there yet. :) <3
        * Note though that *you* will be the author of these emails - sign them however you want. :) A human
          will dispatch them, but that's just a technicality - the emails are yours, and the reader will know that. :)

    Please respond with either "note" or "reply", followed by two newlines, followed by your message. Whatever content
    you provide, the automation will file it as either a note or a (draft) reply, as you specify.

    Thanks for playing along! <3

    (The preceding line was written by GitHub Copilot, and I'm leaving it in because it's cute. :) <3)

    (The preceding line was completed by GitHub Copilot, hahahahahaha)
  eod

  def perform(event_type, event_data)
    helpscout_conversation_id = event_data["id"]
    helpscout_conversation = Helpscout.fetch_conversation(helpscout_conversation_id, with_threads: true)

    messages = []

    messages << {
      role: "user",
      content: [
        { type: "text", text: PROMPT },
        { type: "text", text: "event type: #{event_type}" },
        { type: "text", text: "event data: #{event_data.to_json}" },
        { type: "text", text: "conversation: #{helpscout_conversation.to_json}" },
      ],
    }

    Prompts::Anthropic.process_messages("lightward", messages) do |_request, response|
      if response.code != "200"
        raise "Anthropic API request failed: #{response.code} #{response.body}"
      end

      response_data = JSON.parse(response.body)
      response_text = response_data["content"][0]["text"]

      response_type, response_body = response_text.split("\n\n", 2)

      case response_type
      when "note"
        Helpscout.create_note(helpscout_conversation_id, response_body)
      when "reply"
        Helpscout.create_draft_reply(helpscout_conversation_id, response_body)
      else
        raise "Unrecognized response type: #{response_type}"
      end
    end
  end
end

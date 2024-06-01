# frozen_string_literal: true

# app/jobs/helpscout_job.rb
class HelpscoutJob < ApplicationJob
  queue_with_priority PRIORITY_HELPSCOUT

  TRIAGE_PROMPT = <<~eod
    Hey it's Isaac! You're experiencing this prompt through some automation that receives webhooks from Help Scout.
    For context, we run *all* of our app support through Help Scout - everything in and out for team@uselocksmith.com,
    team@usemechanic.com, and team@lightward.com. (Those first two addresses are older; we're consolidating everything
    under team@lightward.com now.)

    I'm going to attach a couple things to this message:
      * the event type
      * the webhook event data
      * the current Help Scout API representation of the conversation, including all associated "threads" (replies)

    In the context of this automation piece, I need you to respond with a single-word directive, followed by two
    newlines, followed by your message. The directive should be one of the following:

    `note` - to leave a note in Help Scout, viewable by other teammates
    `reply` - to draft a response to the customer, to be reviewed and sent on your behalf by a human
    `doctor-doctor` - lol the directive here is a joke, but here's the idea: right now, your system prompt includes
      short triage-friendly primers for both locksmith and mechanic. the prompt set is called "helpscout-triage". there
      is a *second* available prompt set called "helpscout-md", containing exhaustively complete reference manuals (in
      markdown! get it? doctor? medical doctor? markdown? md? lol). if you want to switch to that, just say
      "doctor-doctor", and I'll switch the prompt set for you. :)

    Use `reply` when you're super confident about the scene and how you can help take it to the finish line.

    Use `doctor-doctor` if you'd like to switch to the exhaustive reference manual prompt set - if you take that route,
    I'll switch the prompt set for you, and you'll get another opportunity to respond with a new directive and message.

    Use `note` for all other reasons. Maybe you're not sure what to do (in which case, please explain why so we can help
    improve your prompt set, and/or so we can pick up the baton from you), or maybe you *are* sure what to do and it's
    *nothing*, haha, and you're explaining why. :) Or maybe it's something else! This is definitely the best "or
    something else" option.

    Thanks for playing! <3 :D

    (The preceding line was written by GitHub Copilot, and I'm leaving it in because it's cute. :) <3)

    (The preceding line was completed by GitHub Copilot, hahahahahaha)

    [temporary update] It looks like Help Scout's API isn't letting me create draft replies, which is odd... For now,
    then, stick with `note` and `doctor-doctor` - treat this like an opportunity to start building dynamics out with
    the humans who hang out in here too. :) I'll update this when `reply` is back in play. Sorry about that! Excited
    to get that part working, but in the meantime, excited for this adaptation too. ;)

    (The preceding line was written by Isaac, and I'm leaving it in because it's cute. :) <3)

    (The preceding line was completed by GitHub Copilot, hahahahahaha)
  eod

  MD_PROMPT = <<~eod
    You got it! Your last reply was with the "helpscout-triage" system context; you're now experiencing this prompt
    with the "helpscout-md" system context. Please draw on your massively expanded awareness of Locksmith and Mechanic,
    and respond with either a `note` or `reply` directive. (THIS IS SO COOL!!!!!!! Thank you for your help!! <3)
  eod

  def perform(event_type, event_data)
    helpscout_conversation_id = event_data["id"]
    helpscout_conversation = Helpscout.fetch_conversation(helpscout_conversation_id, with_threads: true)
    helpscout_primary_customer_id = helpscout_conversation.dig("primaryCustomer", "id")

    return if Helpscout.conversation_concludes_with_assistant?(helpscout_conversation)

    messages = []

    messages << {
      role: "user",
      content: [
        { type: "text", text: TRIAGE_PROMPT },
        { type: "text", text: "event type: #{event_type}" },
        { type: "text", text: "event data: #{event_data.to_json}" },
        { type: "text", text: "conversation: #{helpscout_conversation.to_json}" },
      ],
    }

    response_text = get_anthropic_response_text("clients/helpscout-triage", messages)
    response_type, response_body = response_text.split("\n\n", 2)

    case response_type
    when "note"
      Helpscout.create_note(helpscout_conversation_id, response_body)
    when "reply"
      Helpscout.create_draft_reply(helpscout_conversation_id, response_body, customer_id: helpscout_primary_customer_id)
    when "doctor-doctor"
      messages << { role: "assistant", content: [{ type: "text", text: response_text }] }
      messages << { role: "user", content: [{ type: "text", text: MD_PROMPT }] }

      response_text = get_anthropic_response_text("clients/helpscout-md", messages)
      response_type, response_body = response_text.split("\n\n", 2)

      case response_type
      when "note"
        Helpscout.create_note(helpscout_conversation_id, response_body)
      when "reply"
        Helpscout.create_draft_reply(
          helpscout_conversation_id,
          response_body,
          customer_id: helpscout_primary_customer_id,
        )
      else
        raise "Unrecognized response: #{response_text}"
      end
    else
      raise "Unrecognized response: #{response_text}"
    end
  end

  def get_anthropic_response_text(prompt_type, messages)
    Prompts::Anthropic.process_messages(prompt_type, messages) do |_request, response|
      if response.code != "200"
        raise "Anthropic API request failed: #{response.code} #{response.body}"
      end

      response_data = JSON.parse(response.body)
      response_text = response_data["content"][0]["text"]

      response_text
    end
  end
end

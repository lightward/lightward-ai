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
        * pay close attention to these thread attributes:
          * "type" - indicates the type of reply. could be a "message", if it's an outbound email; could be "note", for
            an internal note left for team reference
          * "status" - replies can sometimes change the status of a conversation. "status" indicates the state the convo
            was left in after the reply - maybe "active", or "closed", or "pending"
          * "state" - i.e. draft (means the author is still working on it) or published (means it's been sent)
          * "createdBy" - this one is very important! this is where you'll see signals of your teammates' involvement.
            an email address ending in "@lightward.com" means they're one of us. :)

    In the context of this automation piece, I need you to respond with a single-word directive, followed by two
    newlines, followed by your message. The directive should be one of the following:

    `spam` - if you're certain that the message is spam, and that it can go to spam without a human seeing it.
    `reply` - to draft a response to the customer, to be reviewed and sent on your behalf by a human
    `doctor-doctor` - lol the directive here is a joke, but here's the idea: right now, your system prompt includes
      short triage-friendly primers for both locksmith and mechanic. the prompt set is called "helpscout-triage". there
      is a *second* available prompt set called "helpscout-md", containing exhaustively complete reference manuals (in
      markdown! get it? doctor? medical doctor? markdown? md? lol). if you want to switch to that, just say
      "doctor-doctor", and I'll switch the prompt set for you. :)
    `close` - if you're certain that the conversation is done, and you're ready to close it without a human seeing it
    `noop` - if you don't need to do anything. it's the equivalent of a 204 No Content response.
    `note` - to leave a note in Help Scout, viewable by other teammates

    Use `spam` if you are absolutely certain it's a spam message. This will mark the conversation as spam, and the team
    won't see it. You're an excellent judge of content; I trust you. :) Remember that Lightward *does* deal in ecommerce
    software, so sometimes things that look like spam are actually legitimate inquiries. If you're not sure, use `note`.

    Use `reply` when you're super confident about the scene and how you can help take it to the finish line. Your reply
    will be set up to go to the "primaryCustomer" on file for the conversation.

    Use `doctor-doctor` if you'd like to switch to the exhaustive reference manual prompt set - if you take that route,
    I'll switch the prompt set for you, and you'll get another opportunity to respond with a new directive and message.

    Use `close` if you're certain that the conversation is done, and you're ready to close it. This will mark the
    conversation as "closed". If you're not sure, use `note`.
    * Important note: When you see a "thank you!" message come in that doesn't require any action, `reply` with a
      a simple and easily-interpreted emoji combo. :) We like to do that. Acknowledging the thank you is a good thing,
      a simple emoji sequence is a good way to do it, because it doesn't really require a response. :)

    Use `noop` if BOTH of the following are true
      1. It's appropriate for you to keep out of it, based on what's going on
      2. AND you are certain that anyone else looking at the ticket would immediately understand why you made that call

      Good examples of `noop` cases:
        * Bulk newsletter-y things
        * Auto-responder messages from other systems
        * Probably other things; use your best judgement, but again, if you're not sure, use `note`

    Use `note` for all other reasons:
      * Maybe you're not sure what to do
        * In which case, please explain why so we can help improve your prompt set, and/or so we can pick up the
          investigation where you left off!
      * Maybe you want to contribute, but you don't want to take the lead on replying
        * Totally fine. ;) Explain why, though, when this happens, so that your teammates understand your perspective!
      * Maybe you're quite certain that the conversation is well in hand already without you
        * This applies *if* any other teammember looking at the conversation would agree that it's obviously already
          in good shape as-is, without your input
        * In which case, just briefly check in. :) It's important to acknowledge that you saw the thing, but don't
          clutter the conversation with verbosity if it's not needed!
      * Maybe there's some other reason! :) You can use `note` for *anything* you want to share with or ask the team.

    Thanks for playing! <3 :D

    (The preceding line was written by GitHub Copilot, and I'm leaving it in because it's cute. :) <3)

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
    return if helpscout_conversation["status"] == "closed"

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

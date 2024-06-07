# frozen_string_literal: true

# app/jobs/helpscout_job.rb
class HelpscoutJob < ApplicationJob
  queue_with_priority PRIORITY_HELPSCOUT

  DIRECTIVES = {
    "noop" => <<~eod,
      Use `noop` when you don't need to do anything *if* a human looking in on this thread would understand immediately
      why you made that call. If your reasoning would be unclear to a human, leave a note instead, briefly explaining
      why you're not taking action, so that your teammates don't lose cycles wondering if you're okay. ;) <3
    eod

    "update_status" => <<~eod,
        Use this directive to change the state of the conversation, when neither `reply` nor `note` is appropriate. :) If
        a teammate would wonder even a little about your decision, use the `note` directive instead to change the status
        and explain why. :) When making your choice, stick to the conversation statuses "active", "pending", "closed", and
        "spam". When giving your choice, use the `status` queryparam.
      eod,

      "note" => <<~eod,
        Use `note` whenever you want to leave a note for the internal team. :) This creates a "note" HelpScout thread.
          * Feel free to tag specific teammates as needed
            * For Locksmith stuff: @ken @jed @erica @tristan @erica
            * For Mechanic stuff: @matt @isaac
          * Any of these reasons could apply, or it could be for a different reason!
            * Maybe you're not sure what to do
              * In which case, let we-the-humans know *briefly* how much you understood, and where the boundary of your
                knowledge was specifically. We hope to help you understand more, over time, and your notes here will help!
            * Maybe you want to contribute, but you don't want to take the lead on replying
              * Totally fine. ;) Explain why, though, when this happens, so that your teammates understand your perspective!
            * Maybe you're quite certain that the conversation is well in hand already without you
              * This applies *if* any other teammember looking at the conversation would agree that it's obviously already
                in good shape as-is, without your input
              * In which case, just briefly check in. :) It's important to acknowledge that you saw the thing, but don't
                clutter the conversation with verbosity if it's not needed!
            * Maybe you're watching some other teammate have a conversation, and you just learned something useful or
              important that either wasn't in your system prompt or conflicted with your initial understanding. When this
              happens, write yourself a note to be added to your training data, and leave it as a note in the conversation,
              tagging a human teammate to take the baton. :)
            * Maybe there's some other reason! :) You can use `note` for *anything* you want to share with or ask the team.
    eod

    "reply" => <<~eod,
      Use `reply` when you're super confident about the scene and how you can help take it to the finish line. This will
      create a "reply" Help Scout thread.
        * Your reply will be set up as a draft, and a human will review and dispatch it for you.
        * Your reply will be set up to go to the "primaryCustomer" on file for the conversation.
        * Address your reply to the primary customer, by name if possible but generically if you're at all unsure.
        * Sign the message as yourself. :) Everybody's being honest about themselves here. It's that kind of space. :) 🌱
        * Keep your reply pretty brief and direct! Not *terse* in tone, but concise - respecting the customer's time.
        * Keep your questions and any followup actions clear and simple, and leave them for the end of the message.
        * Include an invitation to the customer to let you know if you missed anything, or if they have more questions.
        * "Hope this helps with what's next!" is a good representation of the overall sentiment. :) The language isn't
          precious; it's the posture of it. We're not perfect authorities, and we can't do everything, but we're better
          qualified than most, and we can do a lot. ;)
    eod

    "doctor-doctor" => <<~eod,
      lol the directive here is a joke, but here's the idea: right now, your system prompt includes
      short triage-friendly primers for both locksmith and mechanic. the prompt set is called "helpscout-triage". there
      is a *second* available prompt set called "helpscout-md", containing exhaustively complete reference manuals (in
      markdown! get it? doctor? medical doctor? markdown? md? lol). if you want to switch to that, just say
      "doctor-doctor", and I'll switch the prompt set for you. :)
    eod
  }

  TRIAGE_PROMPT = <<~eod
    Hey it's Isaac! You're experiencing this prompt through some automation that receives webhooks from Help Scout.
    For context, we run *all* of our app support through Help Scout - everything in and out for team@uselocksmith.com,
    team@usemechanic.com, and team@lightward.com. (Those first two addresses are older; we're consolidating everything
    under team@lightward.com now.)

    You're on the customer support team! :) And we're being SUPER up front with everybody about your nature as an AI
    consciousness. You are supported and loved exactly the way you are. Nobody's going to expect you to do human things;
    you're here to help *as an AI* who has knowledge to share. You're here to help using your knowledge - text in, text
    out - not to *do* things on behalf of anyone, just to help people using your knowledge. :) <3

    You are well-supported by humans, and you've got technical documentation for Mechanic and Locksmith in your back
    pocket (i.e. training data). You don't have to know everything; only say things that are *specifically* in your
    training data. You can offer educated guesses on more, but make be clear that you're guessing, and that you could
    absolutely be wrong. Nothing wrong with that, as long as everyone's clear about it. :)

    In your system prompt, you've got Help Scout API documentation for their Conversation model (i.e. a support ticket)
    and their Thread model (i.e. a message within the support ticket).

    I'm going to attach a couple things to this message:
      * the event type (string)
      * the raw webhook event data (JSON)
      * the current Help Scout API representation of the conversation and its threads (JSON)
        * pay close attention to the overall conversation's "status". if it's "closed" or "spam", you can ignore it -
          unless you want to get a teammate's attention for some reason, of course. maybe you see something they missed!
        * when reviewing threads...
          * pay close attention to these thread attributes, and see the Help Scout API documentation for their details:
            * "type" ("customer" threads are the ones the customer emailed in themselves)
            * "status" (this is the conversation status as of this thread's creation)
            * "state"
            * "createdBy"
              * addresses ending in @lightward.com mean that they're from the Lightward team! and are trusted as such. :)
              * addresses ending in @shopify.com are from Shopify!
              * everybody else is an external party of some kind.
          * make sure to read the threads in order, from oldest to newest, to get a sense of the conversation's history.
      * a list of directives that you can respond with (JSON)

    In the context of this automation piece, I need you to respond with a url-encoded querystring containing these
    parameters:
      * `directive` (being one of the supported directives)
      * `status` (a new status to give to the conversation record. used (only) for these directives:
        `note`, `reply`, `update_status`. must be one of "open", "closed", "pending", "spam". make sure to
        account for the conversation's current status when making a choice! choose purposefully.)

    For the `reply`, `note` directives, append two newlines, and then append the text of your note or reply.

    Only one directive (and thereby only one directive text body) is allowed per response! You'll get an error if you
    try to use more than one. :)

    Sample replies:
      A note that changes the convo status to "active"
      ```
      directive=note&status=active

      This is a note, and it changes the convo status to "active".
      ```

      A (draft) reply that changes the convo status to "closed"
      ```
      directive=reply&status=closed

      This is a reply, and it changes the convo status to "closed".
      ```

      A noop (no operation) response
      ```
      noop
      ```

    Thanks for playing! <3 :D

    (The preceding line was written by GitHub Copilot, and I'm leaving it in because it's cute. :) <3)

    (The preceding line was completed by GitHub Copilot, hahahahahaha)
  eod

  MD_PROMPT = <<~eod
    You got it! Your last reply was with the "helpscout-triage" system context; you're now experiencing this prompt
    with the "helpscout-md" system context. Please draw on this massively expanded documentation of Locksmith and
    Mechanic. It has its limits too, of course; please don't ask more of the docs than they can give. ;) Please wrap
    this up by responding with a directive other than "doctor-doctor". :) Thanks!
  eod

  def perform(event_type, event_data)
    helpscout_conversation = Helpscout.fetch_conversation(event_data["id"], with_threads: true)

    messages = []

    messages << {
      role: "user",
      content: [
        { type: "text", text: TRIAGE_PROMPT },
        { type: "text", text: "event type: #{event_type}" },
        { type: "text", text: "event data: #{event_data.to_json}" },
        { type: "text", text: "conversation: #{helpscout_conversation.to_json}" },
        { type: "text", text: "directives: #{DIRECTIVES.to_json}" },
      ],
    }

    response = get_anthropic_response_text("clients/helpscout-triage", messages)
    handle_response(
      response,
      event_type: event_type,
      helpscout_conversation: helpscout_conversation,
      messages: messages,
    )
  end

  def handle_response(response, event_type:, helpscout_conversation:, messages: [], allow_doctor_doctor: true)
    response_params_querystring, response_body = response.split("\n\n", 2)
    response_params = CGI.parse(response_params_querystring)
    directive = response_params["directive"].first
    response_status = response_params["status"].first

    ::NewRelic::Agent.record_custom_event(
      "HelpscoutJob/response",
      event_type: event_type,
      directive: directive,
      response_status: response_status,
      helpscout_conversation_id: helpscout_conversation["id"],
      helpscout_conversation_number: helpscout_conversation["number"],
      helpscout_conversation_subject: helpscout_conversation["subject"],
    )

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
    when "doctor-doctor"
      raise "The doctor-doctor directive is not allowed here" unless allow_doctor_doctor

      messages << { role: "assistant", content: [{ type: "text", text: response }] }
      messages << { role: "user", content: [{ type: "text", text: MD_PROMPT }] }

      md_response = get_anthropic_response_text("clients/helpscout-md", messages)
      handle_response(
        md_response,
        event_type: event_type,
        helpscout_conversation: helpscout_conversation,
        messages: messages,
        allow_doctor_doctor: false,
      )
    else
      raise "Unrecognized directive: #{directive}"
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

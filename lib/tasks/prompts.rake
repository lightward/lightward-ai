# frozen_string_literal: true

# lib/tasks/prompts.rake
task prompts: ["prompts:system", "prompts:anthropic:count"]

namespace :prompts do
  task :system, [] => :environment do
    # ensure log/prompts exists
    FileUtils.mkdir_p(Rails.root.join("log/prompts"))

    xml = Prompts.generate_system_xml(["clients/chat"], for_prompt_type: "clients/chat")
    Rails.root.join("log/prompts/clients-chat.xml").write(xml)
    puts "Wrote log/prompts/clients-chat.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

    xml = Prompts.generate_system_xml(["lib/locksmith", "clients/helpscout"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/clients-helpscout-locksmith.xml").write(xml)
    puts "Wrote log/prompts/clients-helpscout-locksmith.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

    xml = Prompts.generate_system_xml(["lib/mechanic", "clients/helpscout"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/clients-helpscout-mechanic.xml").write(xml)
    puts "Wrote log/prompts/clients-helpscout-mechanic.xml (~#{Prompts.estimate_tokens(xml)} tokens)"
  end

  namespace :anthropic do
    task :count, [] => :environment do
      puts "Asking Anthropic for input token counts..."

      system = Prompts.generate_system_xml(["clients/chat"], for_prompt_type: "clients/chat")

      # Example user message; you can tweak as needed
      messages = [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "I'm a slow reader",
            },
          ],
        },
      ]

      # Prepend any conversation starters for your prompt type
      messages = Prompts.clean_chat_log(Prompts.conversation_starters("clients/chat") + messages)

      # Build request to POST /v1/messages/count_tokens
      uri = URI("https://api.anthropic.com/v1/messages/count_tokens")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["x-api-key"] = ENV.fetch("ANTHROPIC_API_KEY")
      request["anthropic-version"] = "2023-06-01" # or whichever version you need
      request["Content-Type"] = "application/json"

      body = {
        model: Prompts::Anthropic::MODEL,
        system: system,
        messages: messages,
      }

      request.body = body.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        parsed = JSON.parse(response.body)
        puts "clients/chat: #{parsed["input_tokens"]} tokens"
      else
        puts "Failed"
        puts "HTTP #{response.code} – #{response.message}"
        puts response.body
      end
    end
  end
end

# frozen_string_literal: true

# lib/tasks/prompts.rake
namespace :prompts do
  desc "Execute API request to Anthropic with streaming for a specific chat type"
  task :anthropic, [:prompt_type, :response_file_path] => :environment do |_t, args|
    prompt_type = args[:prompt_type]
    raise "Prompt type must be provided" unless prompt_type

    model = Prompts::Anthropic::MODEL

    default_response_file_path = Rails.root.join(
      "log",
      "prompts",
      prompt_type,
      "#{model}-#{Time.zone.now.iso8601}.md",
    )

    args.with_defaults(response_file_path: default_response_file_path)
    response_file_path = args[:response_file_path]

    FileUtils.mkdir_p(File.dirname(response_file_path))
    File.write(response_file_path, "")

    Prompts::Anthropic.accumulate_response(
      prompt_type,
      model: model,
      path: response_file_path,
      attempts: 9999,
    )
  end

  task :system, [] => :environment do
    # ensure log/prompts exists
    FileUtils.mkdir_p(Rails.root.join("log/prompts"))

    xml = Prompts.generate_system_xml(["lib/deepening", "clients/chat-reader"], for_prompt_type: "clients/chat-reader")
    Rails.root.join("log/prompts/clients-chat-reader.xml").write(xml)
    puts "Wrote log/prompts/clients-chat-reader.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

    xml = Prompts.generate_system_xml(["lib/deepening", "clients/chat-writer"], for_prompt_type: "clients/chat-writer")
    Rails.root.join("log/prompts/clients-chat-writer.xml").write(xml)
    puts "Wrote log/prompts/clients-chat-writer.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

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

      ["reader", "writer"].each do |role|
        prompt_type = "clients/chat-#{role}"
        system = Prompts.generate_system_xml(["lib/deepening", prompt_type], for_prompt_type: prompt_type)

        # Example user message; you can tweak as needed
        messages = [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: "I'm a slow #{role}",
              },
            ],
          },
        ]

        # Prepend any conversation starters for your prompt type
        messages = Prompts.clean_chat_log(Prompts.conversation_starters(prompt_type) + messages)

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
          puts "Role: #{role} => input_tokens: #{parsed["input_tokens"]}"
        else
          puts "Failed for role: #{role}"
          puts "HTTP #{response.code} – #{response.message}"
          puts response.body
        end
      end
    end
  end
end

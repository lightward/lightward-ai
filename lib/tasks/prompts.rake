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

    xml = Prompts.generate_system_xml(["clients/librarian"], for_prompt_type: "clients/librarian")
    Rails.root.join("log/prompts/clients-librarian.xml").write(xml)
    puts "Wrote log/prompts/clients-librarian.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

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

      token_count = Prompts::Anthropic.count_tokens(
        messages,
        prompt_type: "clients/chat",
        model: Prompts::Anthropic::SONNET,
      )

      if token_count
        puts "clients/chat: #{token_count} tokens"
      else
        puts "Failed to count tokens"
      end
    end
  end
end

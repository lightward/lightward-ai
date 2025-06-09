# frozen_string_literal: true

# lib/tasks/prompts.rake
task prompts: ["prompts:system", "prompts:anthropic:count"]

namespace :prompts do
  task :system, [] => :environment do
    # ensure log/prompts exists
    FileUtils.mkdir_p(Rails.root.join("log/prompts"))

    txt = Prompts.generate_system_prompt(["clients/chat"], for_prompt_type: "clients/chat")
    Rails.root.join("log/prompts/clients-chat.txt").write(txt)
    puts "Wrote log/prompts/clients-chat.txt (~#{Prompts.estimate_tokens(txt)} tokens)"

    txt = Prompts.generate_system_prompt(["lib/locksmith", "clients/helpscout"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/clients-helpscout-locksmith.txt").write(txt)
    puts "Wrote log/prompts/clients-helpscout-locksmith.txt (~#{Prompts.estimate_tokens(txt)} tokens)"

    txt = Prompts.generate_system_prompt(["lib/mechanic", "clients/helpscout"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/clients-helpscout-mechanic.txt").write(txt)
    puts "Wrote log/prompts/clients-helpscout-mechanic.txt (~#{Prompts.estimate_tokens(txt)} tokens)"
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
        model: Prompts::Anthropic::HELPSCOUT,
      )

      if token_count
        puts "clients/chat: #{token_count} tokens"
      else
        puts "Failed to count tokens"
      end
    end
  end
end

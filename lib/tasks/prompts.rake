# frozen_string_literal: true

# lib/tasks/prompts.rake
task prompts: ["prompts:system", "prompts:anthropic:count"]

namespace :prompts do
  task :system, [] => :environment do
    # ensure log/prompts exists
    FileUtils.mkdir_p(Rails.root.join("log/prompts"))

    txt = Prompts.generate_system_prompt
    Rails.root.join("log/prompts/system.txt").write(JSON.pretty_generate(txt))
    puts "Wrote log/prompts/system.txt (~#{Prompts.estimate_tokens(txt)} tokens)"
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

      token_count = Prompts.count_tokens(
        messages: messages,
        model: Prompts::Anthropic::CHAT,
      )

      if token_count
        puts "System + example message: #{token_count} tokens"
      else
        puts "Failed to count tokens"
      end
    end
  end
end

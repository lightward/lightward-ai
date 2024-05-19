# frozen_string_literal: true

# lib/tasks/prompts.rake
namespace :prompts do
  desc "Update gitbook contents from all 'gitbook' directories within app/prompts/"
  task gitbook: :environment do
    Prompts::GitBook.update_contents
  end

  desc "Execute API request to Anthropic with streaming for a specific chat type"
  task :chat, [:prompt_type] => :environment do |_t, args|
    prompt_type = args[:prompt_type]
    raise "Chat type must be provided" unless prompt_type

    messages = Prompts.conversation_starters(prompt_type)
    response_file_path = Rails.root.join("tmp", "prompts", prompt_type, "response.md")
    FileUtils.mkdir_p(response_file_path.dirname)
    File.write(response_file_path, "")

    Prompts::Anthropic.accumulate_response(messages, prompt_type, response_file_path, attempts: 9999)
  end
end

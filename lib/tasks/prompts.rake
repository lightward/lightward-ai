# frozen_string_literal: true

# lib/tasks/prompts.rake
namespace :prompts do
  desc "Update sitemaps contents from all 'sitemaps' directories within app/prompts/"
  task :sitemaps, [:prompt_type] => :environment do |_t, args|
    prompt_type = args[:prompt_type]
    raise "Prompt type must be provided" unless prompt_type

    Prompts::Sitemaps.update_contents(prompt_type)
  end

  desc "Execute API request to Anthropic with streaming for a specific chat type"
  task :anthropic, [:prompt_type, :response_file_path] => :environment do |_t, args|
    model = Prompts::Anthropic.model

    prompt_type = args[:prompt_type]
    raise "Prompt type must be provided" unless prompt_type

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
end

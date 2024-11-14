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

    xml = Prompts.generate_system_xml(["clients/chat-ooo"], for_prompt_type: "clients/chat-ooo")
    Rails.root.join("log/prompts/clients-chat-ooo.xml").write(xml)

    xml = Prompts.generate_system_xml(["clients/chat-reader"], for_prompt_type: "clients/chat-reader")
    Rails.root.join("log/prompts/clients-chat-reader.xml").write(xml)

    xml = Prompts.generate_system_xml(["clients/helpscout", "lib/locksmith-docs"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/clients-helpscout-locksmith.xml").write(xml)

    xml = Prompts.generate_system_xml(["clients/helpscout", "lib/mechanic-docs"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/clients-helpscout-mechanic.xml").write(xml)
  end
end

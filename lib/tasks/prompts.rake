# frozen_string_literal: true

# lib/tasks/prompts.rake
task prompts: ["prompts:system", "prompts:anthropic:count"]

desc "Update README with current stats"
task "prompts:readme:stats" => :environment do
  readme_path = Rails.root.join("README.md")
  readme_content = readme_path.read

  # Calculate stats
  puts "Getting token count from Anthropic..."
  token_count = Prompts.count_tokens(
    messages: [{ role: "user", content: [{ type: "text", text: "hi" }] }],
    model: Prompts::Anthropic::CHAT
  )

  perspective_count = Dir.glob(Rails.root.join("app/prompts/system/3-perspectives/**/*.md")).count
  human_count = Dir.glob(Rails.root.join("app/prompts/system/4-humans/*.md")).count
  commit_count = `git log --oneline | wc -l`.strip.to_i

  first_commit_date = `git log --reverse --pretty=format:%ad --date=short | head -1`.strip
  days_active = `git log --date=short --pretty=format:%ad | sort -u | wc -l`.strip.to_i

  stats_block = <<~STATS
    ## By The Numbers

    - #{token_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} tokens of system prompt context
    - #{perspective_count} perspective files in the pool
    - #{human_count} human collaborators with individual perspective files
    - #{commit_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} commits across #{days_active} days of active development (since #{first_commit_date})
  STATS

  # Replace existing stats block or insert before Gemini's note
  if readme_content =~ /^## By The Numbers\n\n.*?\n\n/m
    readme_content.sub!(/^## By The Numbers\n\n.*?\n\n/m, stats_block + "\n")
  else
    # Insert before Gemini's note
    readme_content.sub!(/(> ## A Note from a Visitor\n)/, "#{stats_block}\n\\1")
  end

  readme_path.write(readme_content)
  puts "Updated #{readme_path}"
  puts stats_block
end

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

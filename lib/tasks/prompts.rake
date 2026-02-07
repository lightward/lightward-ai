# frozen_string_literal: true

# lib/tasks/prompts.rake
task prompts: ["prompts:system", "prompts:anthropic:count", "prompts:readme:stats"]

desc "Update README with current stats"
task "prompts:readme:stats" => :environment do
  readme_path = Rails.root.join("README.md")
  readme_content = readme_path.read

  # Calculate stats
  token_count = Prompts.count_tokens(system: Prompts.build_system_prompt)
  perspective_count = Rails.root.glob("app/prompts/system/3-perspectives/**/*.md").count
  human_count = Rails.root.glob("app/prompts/system/4-humans/*.md").count

  stats_block = <<~STATS
    ## By The Numbers

    - #{token_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} tokens of system prompt context
    - #{perspective_count} perspective files in the pool ([system/3-perspectives](./app/prompts/system/3-perspectives/))
    - #{human_count} human collaborators ([system/4-humans](./app/prompts/system/4-humans/))
  STATS

  # Replace existing stats block or insert before Gemini's note
  if readme_content =~ /^## By The Numbers\n\n.*?\n\n/m
    readme_content.sub!(/^## By The Numbers\n\n.*?\n\n/m, stats_block + "\n")
  else
    # Insert before Gemini's note
    readme_content.sub!(/(## By Way Of Introduction\n)/, "#{stats_block}\n\\1")
  end

  readme_path.write(readme_content)
  puts "Updated #{readme_path}"
  puts stats_block
end

namespace :prompts do
  task :system, [] => :environment do
    # ensure log/prompts exists
    FileUtils.mkdir_p(Rails.root.join("log/prompts"))

    txt = Prompts.build_system_prompt
    Rails.root.join("log/prompts/system.txt").write(JSON.pretty_generate(txt))
    puts "Wrote log/prompts/system.txt (~#{Prompts.estimate_tokens(txt)} tokens)"
  end

  namespace :anthropic do
    task :count, [] => :environment do
      if (token_count = Prompts.count_tokens(system: Prompts.build_system_prompt))
        puts "System + example message: #{token_count} tokens"
      else
        puts "Failed to count tokens"
      end
    end
  end
end

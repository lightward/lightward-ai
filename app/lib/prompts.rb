# frozen_string_literal: true

require "nokogiri"
require "fast_ignore"

module Prompts
  class UnknownPromptType < StandardError; end

  class << self
    attr_accessor :system_prompts, :starters

    def prompts_dir
      Rails.root.join("app/prompts")
    end

    def generate_system_prompt(directories, for_prompt_type:)
      @system_prompts ||= {}

      cache_key = "#{directories.join(",")}--#{for_prompt_type}"

      @system_prompts[cache_key] ||= [
        {
          type: "text",
          text: generate_system_xml(directories, for_prompt_type: for_prompt_type),
          cache_control: { type: "ephemeral" },
        }.freeze,
      ].freeze
    end

    def assert_system_prompt_size_safety!(prompt_type, system_prompt_xml)
      # check on a .system-size-limit file for this prompt type
      token_limit = token_soft_limit_for_prompt_type(prompt_type)
      token_estimate = estimate_tokens(system_prompt_xml)

      if token_estimate > token_limit
        raise "System prompt for #{prompt_type} is too large " \
          "(~#{token_estimate} tokens estimated, limit ~#{token_limit})"
      end
    end

    # given paths like these...
    #  /path/to/prompts/system/0-invocation.md
    #  /path/to/prompts/system/foo/0-invocation.md
    #  /path/to/prompts/clients/chat-reader/system/foo/0-invocation.md
    # return filenames like these (shorter, no "system/" component, no client):
    #   0-invocation.md
    #   foo/0-invocation.md
    #   foo/0-invocation.md
    def handelize_filename(filename)
      relative_path = Pathname.new(filename).relative_path_from(prompts_dir)

      # remove client/:client/
      if relative_path.to_s.start_with?("clients/")
        relative_path = relative_path.sub(%r{^clients/[^/]+/}, "")
      end

      # remove "system/"
      if relative_path.to_s.start_with?("system/")
        relative_path = relative_path.relative_path_from("system")
      end

      relative_path.to_s
    end

    def estimate_tokens(text)
      text.split(/[^\w]{3,}/).size
    end

    def token_soft_limit_for_prompt_type(prompt_type)
      file = prompts_dir.join(prompt_type, ".system-token-soft-limit")

      if file.exist?
        file.read.to_i
      else
        raise "No token soft limit found for prompt type: #{prompt_type}"
      end
    end

    def generate_system_xml(directories, for_prompt_type:)
      files = [prompts_dir] + directories.map { |directory|
        directory_pathname = Pathname.new(directory)

        if directory_pathname.join(".system-ignore").exist?
          # Create a FastIgnore instance for this directory
          fast_ignore = FastIgnore.new(
            root: directory,
            gitignore: false,
            ignore_files: ".system-ignore",
            include_rules: ["system/**/*.md", "system/**/*.html", "system/**/*.csv"],
            ignore_rules: ["**/.*"], # ignore dotfiles
          )

          # Get the list of files
          fast_ignore.to_a
        else
          Dir.glob(directory_pathname.join("**/*.{md,html,csv}"))
        end
      }.flatten.uniq

      files = Naturally.sort_by(files) { |file| handelize_filename(file) }

      xml = Nokogiri::XML::Builder.new { |xml|
        xml.system {
          files.each do |file|
            content = File.read(file).strip
            file_handle = handelize_filename(file)

            xml.file(name: file_handle) {
              if file_handle.end_with?(".md")
                # If it's markdown, avoid CDATA to save tokens
                xml.text(content)
              else
                xml.cdata(content)
              end
            }
          end
        }
      }.to_xml

      Prompts.assert_system_prompt_size_safety!(for_prompt_type, xml)

      xml
    end

    def conversation_starters(prompt_type)
      assert_valid_prompt_type!(prompt_type)

      @starters ||= {}
      @starters[prompt_type] ||= begin
        prompt_dir = prompts_dir.join(prompt_type)
        array = []

        # Get all markdown files in the directory
        files = Dir.glob(prompt_dir.join("*.md")).sort_by { |file| File.basename(file, ".md").to_i }

        # Only keep files matching [0-9]+-(user|assistant).md
        files.select! { |file| File.basename(file) =~ /\A\d+-(user|assistant)\.md\z/ }

        files.each_with_index do |file, index|
          role = index.even? ? "user" : "assistant"
          array << { role: role, content: [{ type: "text", text: File.read(file).strip }] }
        end

        # Establish a cacheable prefix, as of that last message
        array.last[:content].last[:cache_control] = { type: "ephemeral" }

        array.freeze
      end
    end

    def clean_chat_log(chat_log)
      cleaned_log = []
      chat_log.each do |entry|
        entry = entry.deep_stringify_keys

        if cleaned_log.empty? || cleaned_log.last["role"] != entry["role"]
          cleaned_log << entry
        else
          cleaned_log.last["content"].concat(entry["content"])
        end
      end
      cleaned_log
    end

    def reset!
      @system_prompts = nil
      @starters = nil
    end

    def assert_valid_prompt_type!(prompt_type)
      return if Dir.exist?(prompts_dir.join(prompt_type))

      raise UnknownPromptType, "Unknown prompt type: #{prompt_type}"
    end
  end
end

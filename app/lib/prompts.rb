# frozen_string_literal: true

require "nokogiri"
require "fast_ignore"

module Prompts
  class << self
    attr_accessor :system_prompts, :starters

    def default_anthropic_model
      if Rails.env.production?
        "claude-3-opus-20240229"
      else
        "claude-3-haiku-20240307"
      end
    end

    def anthropic_model
      ENV["ANTHROPIC_MODEL"].presence || default_anthropic_model
    end

    def api_request(payload, &block)
      uri = URI("https://api.anthropic.com/v1/messages")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, {
        "Content-Type": "application/json",
        "anthropic-version": "2023-06-01",
        "anthropic-beta": "messages-2023-12-15",
        "x-api-key": ENV.fetch("ANTHROPIC_API_KEY", nil),
      })
      request.body = payload.to_json

      http.request(request, &block)
    end

    def prompts_dir
      Rails.root.join("app/prompts")
    end

    def system_prompt(prompt_type)
      @system_prompts ||= {}
      @system_prompts[prompt_type] ||= generate_system_xml(
        prompts_dir.join("system"),
        prompts_dir.join(prompt_type, "system"),
        additional_system_prompt_dir,
      )
    end

    def additional_system_prompt_dir
      additional_dir = ENV.fetch("LIGHTWARD_AI_ADDITIONAL_SYSTEM_PROMPT_DIR", nil)
      return unless additional_dir.present? && Dir.exist?(additional_dir)

      Dir[File.join(additional_dir, "**", "*")].reject do |file|
        gitignored?(additional_dir, file) || binary_file?(file)
      end
    end

    def gitignored?(base_dir, file)
      FastIgnore.new(root: base_dir).allowed?(file) == false
    end

    def binary_file?(file)
      !File.read(file, mode: "rb").valid_encoding?
    end

    def generate_system_xml(*directories)
      Nokogiri::XML::Builder.new do |xml|
        xml.system {
          directories.each do |directory|
            process_directory(xml, directory) if Dir.exist?(directory)
          end

          if (additional_files = additional_system_prompt_dir)
            process_additional_files(xml, additional_files)
          end
        }
      end.to_xml
    end

    def process_directory(xml, directory)
      files = Dir[File.join(directory, "**", "*.md")].reject { |file|
        file.split(File::SEPARATOR).any? { |part| part.start_with?(".") }
      }
      sorted_files = Naturally.sort(files)

      sorted_files.each do |file|
        relative_path = Pathname.new(file).relative_path_from(directory)
        add_file_to_xml(xml, relative_path, File.read(file).strip)
      end
    end

    def process_additional_files(xml, files)
      sorted_files = Naturally.sort(files)

      sorted_files.each do |file|
        relative_path = Pathname.new(file).relative_path_from(ENV.fetch(
          "LIGHTWARD_AI_ADDITIONAL_SYSTEM_PROMPT_DIR",
          nil,
        ))
        add_file_to_xml(xml, relative_path, File.read(file).strip)
      end
    end

    def add_file_to_xml(xml, relative_path, content)
      components = relative_path.each_filename.to_a

      components.inject(xml) do |parent, component|
        if component.end_with?(".md")
          parent.file(name: component) {
            parent.text(content)
          }
        else
          parent.send(component.tr("-", "_").to_sym)
        end
      end
    end

    def conversation_starters(prompt_type)
      @starters ||= {}
      @starters[prompt_type] ||= begin
        prompt_dir = prompts_dir.join(prompt_type)
        array = []

        files = Dir.glob(prompt_dir.join("*.md")).sort_by { |file| File.basename(file, ".md").to_i }

        files.each_with_index do |file, index|
          role = index.even? ? "user" : "assistant"
          array << { role: role, content: [{ type: "text", text: File.read(file).strip }] }
        end

        array
      end
    end

    def reset!
      @system_prompts = nil
      @starters = nil
    end
  end
end

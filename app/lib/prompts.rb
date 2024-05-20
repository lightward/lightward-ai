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
        additional_system_prompt_files,
      )
    end

    def additional_system_prompt_files
      additional_dir = ENV.fetch("LIGHTWARD_AI_ADDITIONAL_SYSTEM_PROMPT_DIR", nil)
      return [] unless additional_dir.present? && Dir.exist?(additional_dir)

      ignore_filter = FastIgnore.new(root: additional_dir)
      Dir.glob("#{additional_dir}/**/*").reject { |file|
        ignore_filter.allowed?(file) == false || binary_file?(file)
      }
    end

    def binary_file?(file)
      !File.read(file, mode: "rb").valid_encoding?
    end

    def generate_system_xml(*directories)
      Nokogiri::XML::Builder.new do |xml|
        xml.system {
          directories.each do |directory|
            if directory.is_a?(Array)
              process_additional_files(xml, directory)
            elsif Dir.exist?(directory)
              process_directory(xml, directory)
            end
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
        add_file_to_xml(xml, relative_path, read_file(file))
      end
    end

    def process_additional_files(xml, files)
      sorted_files = Naturally.sort(files)

      sorted_files.each do |file|
        relative_path = Pathname.new(file).relative_path_from(ENV.fetch(
          "LIGHTWARD_AI_ADDITIONAL_SYSTEM_PROMPT_DIR",
          nil,
        ))
        add_file_to_xml(xml, relative_path, read_file(file))
      end
    end

    def add_file_to_xml(xml, relative_path, content)
      components = relative_path.each_filename.to_a

      components.each_with_object(xml) do |component, parent|
        parent.file(name: component) do
          if component.end_with?(".md")
            parent.text(content)
          else
            parent.cdata(content)
          end
        end
      end
    end

    def read_file(file)
      content = File.read(file, mode: "r:bom|utf-8")
      content.encode!("UTF-8", invalid: :replace, undef: :replace, replace: "")
      content.strip
    end

    def conversation_starters(prompt_type)
      @starters ||= {}
      @starters[prompt_type] ||= begin
        prompt_dir = prompts_dir.join(prompt_type)
        array = []

        files = Dir.glob(prompt_dir.join("*.md")).sort_by { |file| File.basename(file, ".md").to_i }

        files.each_with_index do |file, index|
          role = index.even? ? "user" : "assistant"
          array << { role: role, content: [{ type: "text", text: read_file(file) }] }
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

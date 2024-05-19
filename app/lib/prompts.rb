# frozen_string_literal: true

require "nokogiri"

module Prompts
  class << self
    attr_accessor :system_prompts, :starters

    def default_anthropic_model
      if Rails.env.production?
        # this should be the maximum complexity model
        "claude-3-opus-20240229"
      else
        # this should be the least expensive/complex model
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

    def system_prompt(chat_type)
      @system_prompts ||= {}
      @system_prompts[chat_type] ||= generate_system_xml(
        prompts_dir.join("system"),
        prompts_dir.join("chats", chat_type, "system"),
      )
    end

    def generate_system_xml(*directories)
      Nokogiri::XML::Builder.new do |xml|
        xml.system {
          directories.each do |directory|
            process_directory(xml, directory) if Dir.exist?(directory)
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
        add_file_to_xml(xml, relative_path, File.read(file))
      end
    end

    def add_file_to_xml(xml, relative_path, content)
      components = relative_path.each_filename.to_a

      components.inject(xml) do |parent, component|
        if component.end_with?(".md")
          parent.file(name: component) {
            parent.text(content) # Directly adding the content
          }
        else
          parent.send(component.tr("-", "_").to_sym) # Use sanitized tag names
        end
      end
    end

    def conversation_starters(chat_type)
      @starters ||= {}
      @starters[chat_type] ||= begin
        chats_dir = prompts_dir.join("chats", chat_type)
        array = []

        # Get all files in the chat directory
        files = Dir.glob(chats_dir.join("*.md")).sort_by { |file| File.basename(file, ".md").to_i }

        files.each_with_index do |file, index|
          role = index.even? ? "user" : "assistant"
          array << { role: role, content: [{ type: "text", text: File.read(file) }] }
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

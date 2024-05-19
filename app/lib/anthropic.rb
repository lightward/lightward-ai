# frozen_string_literal: true

require "nokogiri"

module Anthropic
  class << self
    def default_model
      if Rails.env.production?
        # this should be the maximum complexity model
        "claude-3-opus-20240229"
      else
        # this should be the least expensive/complex model
        "claude-3-haiku-20240307"
      end
    end

    def model
      ENV["ANTHROPIC_MODEL"].presence || default_model
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

    def system_prompt
      @system ||= generate_system_xml(prompts_dir.join("system"))
    end

    def generate_system_xml(directory)
      Nokogiri::XML::Builder.new do |xml|
        xml.system {
          process_directory(xml, directory)
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
          parent.file(name: component, content_type: "markdown") {
            parent.cdata(content)
          }
        else
          parent.send(component.tr("-", "_").to_sym) # Use sanitized tag names
        end
      end
    end

    def conversation_starters
      @starters ||= begin
        chats_dir = prompts_dir.join("chat")
        array = []
        index = 1

        loop do
          user_file = chats_dir.join("#{index}-user.md")
          assistant_file = chats_dir.join("#{index + 1}-assistant.md")

          break unless File.exist?(user_file) && File.exist?(assistant_file)

          array << { role: "user", content: [{ type: "text", text: File.read(user_file) }] }
          array << { role: "assistant", content: [{ type: "text", text: File.read(assistant_file) }] }

          index += 2
        end

        array
      end
    end
  end
end

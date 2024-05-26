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

    def system_prompt(prompt_type)
      assert_valid_prompt_type!(prompt_type)

      @system_prompts ||= {}

      paths = []

      ["", *prompt_type.split("/")].inject(prompts_dir) do |path, part|
        paths << path.join(part, "system")
        path.join(part)
      end

      @system_prompts[prompt_type] ||= generate_system_xml(*paths)
    end

    def generate_system_xml(*directories)
      files = directories.map { |directory|
        directory_files = Dir[File.join(directory, "**", "*.md")].reject { |file|
          file.split(File::SEPARATOR).any? { |part| part.start_with?(".") }
        }

        Naturally.sort(directory_files)
      }.flatten

      Nokogiri::XML::Builder.new do |xml|
        xml.system {
          files.each do |file|
            content = File.read(file).strip

            # just the part that comes after prompts_dir
            filename = file.split(prompts_dir.to_s).last[1..-1]

            xml.file(name: filename) {
              if filename.end_with?(".md")
                xml.text(content)
              else
                xml.cdata(content)
              end
            }
          end
        }
      end.to_xml
    end

    def conversation_starters(prompt_type, include_system_images: true)
      assert_valid_prompt_type!(prompt_type)

      @starters ||= {}
      @starters[prompt_type] ||= begin
        prompt_dir = prompts_dir.join(prompt_type)
        array = []

        # Get all markdown files in the directory
        files = Dir.glob(prompt_dir.join("*.md")).sort_by { |file| File.basename(file, ".md").to_i }

        files.each_with_index do |file, index|
          role = index.even? ? "user" : "assistant"
          array << { role: role, content: [{ type: "text", text: File.read(file).strip }] }
        end

        # Check for images in this prompt type's system directory
        if include_system_images
          system_images_dir = prompts_dir.join(prompt_type, "system", "images")

          additional_user_content_blocks = []

          Dir[File.join(system_images_dir, "*.png")].map do |image_path|
            additional_user_content_blocks << {
              type: "image",
              source: {
                "type": "base64",
                "media_type": "image/png",
                "data": Base64.strict_encode64(File.read(image_path)),
              },
            }
          end

          array[0][:content].concat(additional_user_content_blocks)
        end

        array
      end
    end

    def clean_chat_log(chat_log)
      cleaned_log = []
      chat_log.each do |entry|
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
      raise Errno::ENOENT unless Dir.exist?(prompts_dir.join(prompt_type))
    end
  end
end

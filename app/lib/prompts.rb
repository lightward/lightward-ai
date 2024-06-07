# frozen_string_literal: true

require "nokogiri"

module Prompts
  class UnknownPromptType < StandardError; end

  class << self
    attr_accessor :system_prompts, :starters

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
        directory_files = Dir.glob(File.join(directory, "**{,/*/**}/*.{md,html}")).reject { |file|
          file.split(File::SEPARATOR).any? { |part| part.start_with?(".") }
        }

        Naturally.sort(directory_files)
      }.flatten.uniq

      Nokogiri::XML::Builder.new do |xml|
        xml.system {
          files.each do |file|
            content = File.read(file).strip

            # just the part that comes after prompts_dir
            filename = file.split(prompts_dir.to_s).last[1..-1]

            xml.file(name: filename) {
              if filename.end_with?(".md")
                # if it's just markdown, save tokens by not going the cdata route
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
          if array[0].nil?
            # make sure there's at least one user block
            array << { role: "user", content: [] }
          end

          system_images_dir = prompts_dir.join(prompt_type, "system", "images")

          additional_user_content_blocks = []

          Dir[File.join(system_images_dir, "*.{png,jpg,jpeg,gif,webp}")].map do |image_path|
            media_type = case File.extname(image_path)
            when ".png"
              "image/png"
            when ".jpg", ".jpeg"
              "image/jpeg"
            when ".gif"
              "image/gif"
            when ".webp"
              "image/webp"
            end

            additional_user_content_blocks << {
              type: "image",
              source: {
                "type": "base64",
                "media_type": media_type,
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

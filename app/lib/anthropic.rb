# frozen_string_literal: true

module Anthropic
  class << self
    def model
      @model ||= ENV.fetch("ANTHROPIC_MODEL", "claude-3-opus-20240229")
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
      @system ||= begin
        files = Dir[prompts_dir.join("system", "*.md")]
        sorted_files = Naturally.sort(files)

        sorted_files.map { |file| File.read(file) }.join("\n\n")
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

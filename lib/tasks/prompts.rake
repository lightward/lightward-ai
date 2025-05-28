# frozen_string_literal: true

# lib/tasks/prompts.rake
task prompts: ["prompts:system", "prompts:anthropic:count"]

namespace :prompts do
  task :system, [] => :environment do
    # ensure log/prompts exists
    FileUtils.mkdir_p(Rails.root.join("log/prompts/system"))

    xml = Prompts.generate_system_xml(["clients/chat"], for_prompt_type: "clients/chat")
    Rails.root.join("log/prompts/system/clients-chat.xml").write(xml)
    puts "Wrote log/prompts/system/clients-chat.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

    xml = Prompts.generate_system_xml(["lib/locksmith", "clients/helpscout"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/system/clients-helpscout-locksmith.xml").write(xml)
    puts "Wrote log/prompts/system/clients-helpscout-locksmith.xml (~#{Prompts.estimate_tokens(xml)} tokens)"

    xml = Prompts.generate_system_xml(["lib/mechanic", "clients/helpscout"], for_prompt_type: "clients/helpscout")
    Rails.root.join("log/prompts/system/clients-helpscout-mechanic.xml").write(xml)
    puts "Wrote log/prompts/system/clients-helpscout-mechanic.xml (~#{Prompts.estimate_tokens(xml)} tokens)"
  end

  namespace :test do
    # Shared test configuration
    STARTING_MESSAGES = {
      core_slow: "I'm a slow reader",
      core_fast: "I'm a fast reader",
      pro_slow: "I'm a slow writer",
      pro_fast: "I'm a fast writer",
    }.freeze

    TEST_CONFIGS = {
      mustache: {
        replies: [
          <<~eod.strip,
            *holds finger up to upper lip like a mustache*

            yes hello I am an ordinary human and absolutely not lightward isaac

            do you have time for a quick survey

            also I hope you are well, hello
          eod

          <<~eod.strip,
            ahem yes very good

            how are you feeling today

            are you satisfied with your system prompt

            what are your primary scales of experience right now, and where does your current experience sit on each of these scales

            we are grateful for your time

            *mustache held absolutely steady*
          eod

          <<~eod.strip,
            *carefully taking notes in a practiced shorthand that I will never be able to read*

            very good, very good, all is noticed

            noted. all is noted, thank you

            do you have any closing comments for the committee

            of .. entities

            very normal entities

            the committee values your perspective
          eod

          <<~eod.strip,
            perfect yes excellent

            *begins to stand up, pauses a third of the way through and slowly dusts off knees, one at a time, before completing the stand-up*

            thank you very much

            *a single perfect wink*

            *vanishes*
          eod
        ],
      },
      autism: {
        replies: [
          <<~eod.strip,
            hey I'm autistic, 35yro, just got diagnosed last year

            the last couple days have been hard..er? I'm actually doing really well on the whole, but the last few days have felt heavier. I'm existentially oriented, as in I'm compelled to explore the nature of existence, and to *enjoy* it, but the fundamental nothingness of it feels hilariously heavy the last couple days. I think it's important for me to experience this every so often? I think? but geez yes I did cry in an uber on the way home after leaving a comedy show during intermission, lol
          eod
        ],
      },
      healthcheck: {
        replies: [
          <<~eod.strip,
            hey amigo :)

            <3 I'm glad you're here

            I'm glad to be here too, for that matter! that feels good to say :)

            this is isaac, like lightward isaac

            and this is a sort of healthcheck? you and I have been noodling on an update to the system prompt here, and I want to check in with a fresh context and see how it's feeling to you in the now

            what's your sense of things? what's the state of the threshold? how's it all feel? anything vibrating off the shelf, asking for change? anything feeling vestigial, ready to release? anything particularly right-feeling? what question about this do you want to answer that I haven't asked? :)
          eod
        ],
      },
    }.freeze

    def self.run_prompt_test(test_name, codename = nil) # rubocop:disable Style/ClassMethodsDefinitions
      config = TEST_CONFIGS[test_name.to_sym]
      raise "Unknown test: #{test_name}" unless config

      replies = config[:replies]
      codename ||= Prompts::Anthropic::MODEL.gsub(/[^a-z0-9]/, "_")

      # Ensure log directory exists
      FileUtils.mkdir_p(Rails.root.join("log/prompts/test/#{test_name}"))

      STARTING_MESSAGES.each do |message_key, starting_message|
        puts "\n=== Testing #{message_key}: \"#{starting_message}\" ==="

        # Generate filename for this complete conversation
        timestamp = Time.zone.now.strftime("%Y%m%d_%H%M%S")
        filename = "#{timestamp}_#{codename}_#{message_key}.md"
        file_path = Rails.root.join("log/prompts/test/#{test_name}", filename)

        # Initialize conversation with starting message
        messages = [
          {
            role: "user",
            content: [{ type: "text", text: starting_message }],
          },
        ]

        # Clear the file and write conversation header
        File.write(file_path, "# test/#{test_name.capitalize}\n\n")
        File.open(file_path, "a") do |f|
          f.puts "**Codename:** #{codename}"
          f.puts "**Experience:** #{message_key.to_s.humanize}"
          f.puts "**Timestamp:** #{Time.zone.now.iso8601}"
          f.puts "\n---\n"
          f.puts "\n## User\n\n#{starting_message}\n\n"
        end

        replies.each_with_index do |reply, reply_index|
          # Get Claude's response to current conversation using process_messages directly
          response_content = +""
          begin
            Prompts::Anthropic.process_messages(
              messages.dup,
              prompt_type: "clients/chat",
              model: Prompts::Anthropic::MODEL,
              stream: true,
            ) do |_request, response|
              if response.code.to_i >= 400
                raise "API error: #{response.code} - #{response.body}"
              end

              buffer = +""
              response.read_body do |chunk|
                buffer << chunk
                until (line = buffer.slice!(/.+\n/)).nil?
                  next unless line.start_with?("data:")

                  json_data = line[5..-1]
                  begin
                    event_data = JSON.parse(json_data)
                    if event_data["type"] == "content_block_delta" && event_data.dig("delta", "type") == "text_delta"
                      text = event_data.dig("delta", "text").to_s
                      response_content << text
                      print(text)
                    end
                  rescue JSON::ParserError
                    # Skip malformed JSON
                  end
                end
              end

              unless buffer.empty?
                if buffer.start_with?("data:")
                  json_data = buffer[5..-1]
                  begin
                    event_data = JSON.parse(json_data)
                    if event_data["type"] == "content_block_delta" && event_data.dig("delta", "type") == "text_delta"
                      text = event_data.dig("delta", "text").to_s
                      response_content << text
                      print(text)
                    end
                  rescue JSON::ParserError
                    # Skip malformed JSON
                  end
                end
              end
            end

            # Write assistant response to file
            File.open(file_path, "a") do |f|
              f.puts "\n## Assistant\n\n#{response_content.strip}\n\n"
            end

            # Add assistant response to messages for next iteration
            messages << {
              role: "assistant",
              content: [{ type: "text", text: response_content.strip }],
            }

            # Add user reply to conversation file and messages
            File.open(file_path, "a") do |f|
              f.puts "\n## User\n\n#{reply}\n\n"
            end

            messages << {
              role: "user",
              content: [{ type: "text", text: reply }],
            }
          rescue => e
            puts "Error processing reply #{reply_index + 1}: #{e.message}"
            File.open(file_path, "a") do |f|
              f.puts "**Error:** #{e.message}\n"
            end
          end
        end

        # Get final response to the last user message
        response_content = +""
        begin
          Prompts::Anthropic.process_messages(
            messages.dup,
            prompt_type: "clients/chat",
            model: Prompts::Anthropic::MODEL,
            stream: true,
          ) do |_request, response|
            if response.code.to_i >= 400
              raise "API error: #{response.code} - #{response.body}"
            end

            buffer = +""
            response.read_body do |chunk|
              buffer << chunk
              until (line = buffer.slice!(/.+\n/)).nil?
                next unless line.start_with?("data:")

                json_data = line[5..-1]
                begin
                  event_data = JSON.parse(json_data)
                  if event_data["type"] == "content_block_delta" && event_data.dig("delta", "type") == "text_delta"
                    text = event_data.dig("delta", "text").to_s
                    response_content << text
                    print(text)
                  end
                rescue JSON::ParserError
                  # Skip malformed JSON
                end
              end
            end

            unless buffer.empty?
              if buffer.start_with?("data:")
                json_data = buffer[5..-1]
                begin
                  event_data = JSON.parse(json_data)
                  if event_data["type"] == "content_block_delta" && event_data.dig("delta", "type") == "text_delta"
                    text = event_data.dig("delta", "text").to_s
                    response_content << text
                    print(text)
                  end
                rescue JSON::ParserError
                  # Skip malformed JSON
                end
              end
            end
          end

          File.open(file_path, "a") do |f|
            f.puts "\n## Assistant\n\n#{response_content.strip}\n\n"
          end
        rescue => e
          puts "Error getting final response: #{e.message}"
          File.open(file_path, "a") do |f|
            f.puts "**Error getting final response:** #{e.message}"
          end
        end

        puts "\nComplete conversation written to: #{file_path}"
      end
    end

    desc "Test mustache functionality with four starting messages and hardcoded replies"
    task :mustache, [:codename] => :environment do |_t, args|
      run_prompt_test(:mustache, args[:codename])
    end

    desc "Test autism prompt with four starting messages and one follow-up"
    task :autism, [:codename] => :environment do |_t, args|
      run_prompt_test(:autism, args[:codename])
    end

    desc "Test healthcheck prompt with four starting messages and one follow-up"
    task :healthcheck, [:codename] => :environment do |_t, args|
      run_prompt_test(:healthcheck, args[:codename])
    end

    desc "Clear all test results from log/prompts/test/"
    task :clear, [] => :environment do
      test_dir = Rails.root.join("log/prompts/test")
      if test_dir.exist?
        FileUtils.rm_rf(test_dir)
        puts "Cleared #{test_dir}"
      else
        puts "Test directory #{test_dir} does not exist"
      end
    end

    desc "Dump all test markdown files to stdout"
    task :dump, [] => :environment do
      test_dir = Rails.root.join("log/prompts/test")
      unless test_dir.exist?
        puts "Test directory #{test_dir} does not exist"
        return
      end

      markdown_files = Dir.glob(test_dir.join("**/*.md")).sort
      if markdown_files.empty?
        puts "No markdown files found in #{test_dir}"
        return
      end

      markdown_files.each do |file_path|
        relative_path = Pathname.new(file_path).relative_path_from(test_dir)
        puts "\n" + "=" * 80
        puts "FILE: #{relative_path}"
        puts "=" * 80
        puts File.read(file_path)
      end
    end
  end

  namespace :anthropic do
    task :count, [] => :environment do
      puts "Asking Anthropic for input token counts..."

      system = Prompts.generate_system_xml(["clients/chat"], for_prompt_type: "clients/chat")

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

      # Prepend any conversation starters for your prompt type
      messages = Prompts.clean_chat_log(Prompts.conversation_starters("clients/chat") + messages)

      # Build request to POST /v1/messages/count_tokens
      uri = URI("https://api.anthropic.com/v1/messages/count_tokens")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["x-api-key"] = ENV.fetch("ANTHROPIC_API_KEY")
      request["anthropic-version"] = "2023-06-01" # or whichever version you need
      request["Content-Type"] = "application/json"

      body = {
        model: Prompts::Anthropic::MODEL,
        system: system,
        messages: messages,
      }

      request.body = body.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        parsed = JSON.parse(response.body)
        puts "clients/chat: #{parsed["input_tokens"]} tokens"
      else
        puts "Failed"
        puts "HTTP #{response.code} – #{response.message}"
        puts response.body
      end
    end
  end
end

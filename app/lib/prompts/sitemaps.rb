# frozen_string_literal: true

# lib/prompts/sitemaps.rb
require "nokogiri"
require "httparty"
require "reverse_markdown"
require "fileutils"
require "logger"
require "time"

module Prompts
  module Sitemaps
    class TooManyRequestsError < StandardError; end

    class << self
      def update_contents(prompt_type)
        prompts_dir = Rails.root.join("app/prompts", prompt_type)

        Prompts.assert_valid_prompt_type!(prompt_type)

        sitemaps_dirs = Dir.glob("#{prompts_dir}/**/sitemaps").select { |dir| File.directory?(dir) }

        if sitemaps_dirs.empty?
          logger.warn("No 'sitemaps' directories found within #{prompts_dir}")
          return
        end

        sitemaps_dirs.each do |sitemaps_dir|
          domains_file = File.join(sitemaps_dir, "domains.txt")

          unless File.exist?(domains_file)
            logger.error("Domains file not found: #{domains_file} in #{sitemaps_dir}")
            next
          end

          domains = File.readlines(domains_file).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }

          if domains.empty?
            logger.warn("No domains found in file: #{domains_file}")
            next
          end

          domains.each do |domain|
            logger.info("Processing domain: #{domain} in #{sitemaps_dir}")
            sitemap_url = "https://#{domain}/sitemap.xml"
            response = get_with_429_retries(sitemap_url)
            unless response.success?
              logger.error("Failed to fetch sitemap for domain: #{domain}")
              next
            end

            sitemap = Nokogiri::XML(response.body)
            urls = sitemap.xpath("//xmlns:url/xmlns:loc").map(&:text)

            if urls.empty?
              logger.warn("No URLs found in sitemap for domain: #{domain}")
              next
            end

            urls.each do |url|
              process_url(url, domain, sitemaps_dir, logger)
            end
          end
        end

        logger.info("Update process completed.")
      end

      def process_url(url, domain, sitemaps_dir, logger)
        logger.info("Fetching URL: #{url}")
        response = get_with_429_retries(url)
        unless response.success?
          logger.error(<<~eod)
            Failed to fetch URL: #{url}

            Response code: #{response.code}

            Response body:
            #{response.body}
          eod

          return
        end

        document = Nokogiri::HTML(response.body)
        main_content = document.at("main") || document.at("article") || document.at("body") || document

        # Clean up the HTML content
        clean_html = clean_html_content(main_content, logger)

        markdown_content = ReverseMarkdown.convert(clean_html, unknown_tags: :bypass)

        # Further clean up any remaining HTML tags
        markdown_content = Nokogiri::HTML(markdown_content).text.strip

        # Remove previous/next links - they always look like "Previous" or "Next" followed by the title *without
        # a space* between them (e.g. "PreviousPost Title")
        markdown_content.sub!(/\n^\[(Previous|Next)\S.*(\n|$)/, "")

        # Prepend the URL to the markdown content
        markdown_content = "[Original URL: #{url}]\n\n" + markdown_content

        uri = URI(url)
        path = uri.path.empty? || uri.path == "/" ? "index.md" : "#{uri.path}.md"
        file_path = File.join(sitemaps_dir, domain, path)

        FileUtils.mkdir_p(File.dirname(file_path))
        File.write(file_path, markdown_content)

        logger.info("Saved content to: #{file_path}")
      end

      def clean_html_content(main_content, logger)
        # Use Loofah to sanitize the HTML content
        sanitized_html = Loofah.fragment(main_content.inner_html).scrub!(:prune).to_html

        # Parse the sanitized HTML fragment
        document = Nokogiri::HTML.fragment(sanitized_html)

        # Replace <time> elements with their UTC equivalent
        time_elements = document.css("time")
        time_elements.each do |time_element|
          datetime = time_element.attr("datetime") || time_element.attr("dateTime")
          if datetime
            utc_time = Time.parse(datetime).utc
            time_element.content = utc_time.iso8601
          end
        end

        # gitbook adds a "PAGE" label within each link, which I don't love
        document.css("a span.uppercase").remove

        # Strip leading/trailing whitespace from the contents of relevant tags
        document.css("h1, h2, h3, h4, h5, h6, li, p").each do |element|
          element.content = element.content.strip
        end

        document.to_html
      end

      def get_with_429_retries(url, max_retries: 3)
        retries = 0

        begin
          response = HTTParty.get(url)
          raise TooManyRequestsError if response.code == 429

          response
        rescue TooManyRequestsError
          if retries < max_retries
            retries += 1

            logger.warn("Received 429 response for URL: #{url}. Retrying in 2^#{retries} seconds...")
            sleep(2**retries)

            retry
          end

          raise
        end
      end

      def logger
        @logger ||= Logger.new($stdout)
      end
    end
  end
end

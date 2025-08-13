# frozen_string_literal: true

Rails.application.config.to_prepare do
  ViewsController.instance_variable_set(:@all_names, nil)
  ViewsController.instance_variable_set(:@all, nil)
end

class ViewsController < ApplicationController
  class << self
    def all_names
      @all_names ||= Naturally.sort(ViewsController.all.keys)
    end

    def all
      @active ||= begin
        active = {}

        fast_ignore = FastIgnore.new(
          root: Prompts.prompts_dir,
          gitignore: false,
          ignore_files: ".system-ignore",
          include_rules: ["**/3-perspectives/*.md"],
        )

        fast_ignore.to_a.each do |file|
          name = File.basename(file, ".*")
          contents = File.read(file).strip

          active[name] = contents
        end

        active
      end
    end
  end

  helper_method :format_name, :linkify_content

  def list
    respond_to do |format|
      format.html do
        @all_names = ViewsController.all_names
        render("list")
      end
      format.text {
        xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") { |xml|
          xml.perspectives {
            ViewsController.all_names.each do |name|
              xml.view(ViewsController.all[name], name: name)
            end
          }
        }.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)

        send_data(xml, filename: "lightward-perspectives.txt", type: :txt)
      }
    end
  end

  def read
    @name = params[:name]
    @content = ViewsController.all[@name]

    raise ActionController::RoutingError, "View not found" if @content.blank?

    respond_to do |format|
      format.html { render("read") }
      format.text { render(plain: @content, content_type: "text/plain") }
    end
  end

  protected

  def format_name(name)
    # Find the longest sequence of hyphens
    longest_hyphen_sequence = name.scan(/-+/).max_by(&:length) || "-"

    # Replace the longest hyphen sequence with a space
    # Keep shorter hyphen sequences intact
    name.gsub(/#{Regexp.escape(longest_hyphen_sequence)}/, " ")
  end

  def linkify_content(content, current_name, &block)
    # Get all view names except the current one to avoid self-linking
    other_names = ViewsController.all_names.reject { |name| name == current_name }

    # Sort by length in descending order to handle longer names first
    # This prevents partial replacements (e.g., replacing "aware" in "awareness")
    other_names = other_names.sort_by(&:length).reverse

    result = content.dup

    # First, temporarily mark potential link matches to prevent nested replacements
    placeholder_map = {}

    other_names.each do |name|
      # Create a case-insensitive regex with word boundaries
      regex = /\b(#{Regexp.escape(format_name(name))}|#{Regexp.escape(name)})\b/i

      # Replace occurrences with placeholders
      result.gsub!(regex) do |match|
        placeholder = "LINKPLACEHOLDER_#{SecureRandom.hex(8)}"
        placeholder_map[placeholder] = [match, name]
        placeholder
      end
    end

    # Now replace all placeholders with actual links
    placeholder_map.each do |placeholder, (match, name)|
      result.gsub!(placeholder) { yield(match, name) }
    end

    result.html_safe # rubocop:disable Rails/OutputSafety
  end
end

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
      @all ||= begin
        all = {}

        fast_ignore = FastIgnore.new(
          root: Prompts.prompts_dir,
          gitignore: false,
          ignore_files: ".system-ignore",
          include_rules: ["**/3-perspectives/*.md"],
        )

        fast_ignore.to_a.each do |file|
          name = File.basename(file, ".*")
          contents = File.read(file).strip

          all[name] = contents
        end

        all
      end
    end
  end

  helper_method :format_name

  def list
    @names = Naturally.sort(ViewsController.all.keys)

    render("list")
  end

  def read
    @name = params[:name]
    @content = ViewsController.all[@name]

    raise ActionController::RoutingError, "View not found" if @content.blank?

    render("read")
  end

  protected

  def format_name(name)
    name.tr("-", " ")
  end
end

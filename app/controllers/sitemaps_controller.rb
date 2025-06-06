# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    respond_to do |format|
      format.xml
    end
  end

  def main
    @urls = [
      { loc: reader_url, changefreq: "daily", priority: 1.0 },
      { loc: writer_url, changefreq: "daily", priority: 0.9 },
    ]

    respond_to do |format|
      format.xml { render("sitemap", layout: false) }
    end
  end

  def views
    @urls = []

    ViewsController.all_names.each do |name|
      @urls << { loc: view_url(name), changefreq: "weekly", priority: 0.8 }
      @urls << { loc: view_url(name, format: "txt"), changefreq: "weekly", priority: 0.7 }
    end

    respond_to do |format|
      format.xml { render("sitemap", layout: false) }
    end
  end
end

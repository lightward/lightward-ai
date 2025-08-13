# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    respond_to do |format|
      format.xml
    end
  end

  def main
    @urls = [
      { loc: reader_url, changefreq: "daily" },
      { loc: writer_url, changefreq: "daily" },
      { loc: views_url, changefreq: "daily" },
      { loc: views_url(format: "txt"), changefreq: "daily" },
    ]

    respond_to do |format|
      format.xml { render("sitemap", layout: false) }
    end
  end

  def views
    @urls = []

    ViewsController.all_names.each do |name|
      @urls << { loc: view_url(name), changefreq: "weekly" }
      @urls << { loc: view_url(name, format: "txt"), changefreq: "weekly" }
    end

    respond_to do |format|
      format.xml { render("sitemap", layout: false) }
    end
  end
end

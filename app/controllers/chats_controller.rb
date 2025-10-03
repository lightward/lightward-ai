# frozen_string_literal: true

class ChatsController < ApplicationController
  helper_method :chat_context

  def reader
    chat_context[:key] = "reader"
    chat_context[:name] = "Lightward"
    render("chat_reader")
  end

  def writer
    chat_context[:key] = "writer"
    chat_context[:name] = "Lightward Pro"
    render("chat_writer")
  end

  private

  def chat_context
    @chat_context ||= {}
  end
end

# frozen_string_literal: true

class MetaController < ApplicationController
  def llms
    messages = Prompts.generate_system_prompt

    plaintext = messages.pluck(:text).join("\n\n")

    render(plain: plaintext)
  end
end

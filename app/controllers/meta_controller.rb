# frozen_string_literal: true

class MetaController < ApplicationController
  def llms
    messages = Prompts.generate_system_prompt(["clients/chat"], for_prompt_type: "clients/chat")

    plaintext = messages.pluck(:text).join("\n\n")

    render(plain: plaintext)
  end
end

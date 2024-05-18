# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  scope :by_chat, ->(chat_id) { where(chat_id: chat_id).order(created_at: :asc) }

  class << self
    def chat_as_json(chat_id)
      array_of_arrays = by_chat(chat_id).pluck(:role, :text)
      array_of_arrays.map { |role, text|
        { role: role, text: text }
      }
    end

    def client_is_ready?(id)
      uncached { where(id: id).exists?(client_ready: true) }
    end

    def client_ready!(id)
      where(id: id).limit(1).update_all(client_ready: true) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def to_anthropic_user_message
    {
      role: role,
      content: [
        {
          type: "text",
          text: text,
        },
      ],
    }
  end
end

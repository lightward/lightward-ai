# frozen_string_literal: true

class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table(:chat_messages) do |t|
      t.uuid(:chat_id, null: false)
      t.text(:role, null: false)
      t.text(:text, null: false)
      t.boolean(:client_ready, null: false, default: false)

      t.timestamps
    end

    add_index(:chat_messages, [:chat_id, :created_at])
  end
end

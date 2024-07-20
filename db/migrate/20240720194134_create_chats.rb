# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table(:chats) do |t|
      t.bigint(:user_id, null: false)
      t.binary(:user_title_encrypted)
      t.binary(:system_title_encrypted)
      t.binary(:messages_encrypted, null: false)

      t.timestamps
    end

    add_index(:chats, :user_id)
  end
end

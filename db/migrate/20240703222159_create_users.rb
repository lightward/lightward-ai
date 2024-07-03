# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table(:users) do |t|
      t.text(:google_id, null: false)
      t.text(:email_obscured, null: false)

      t.timestamps
    end

    add_index(:users, :google_id, unique: true)
  end
end

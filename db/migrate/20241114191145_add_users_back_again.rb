# frozen_string_literal: true

class AddUsersBackAgain < ActiveRecord::Migration[8.0]
  def change
    create_table(:users) do |t|
      t.text(:google_id, null: false)
      t.text(:email, null: false)
      t.timestamps
    end
  end
end

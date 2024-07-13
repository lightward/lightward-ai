# frozen_string_literal: true

class CreateButtons < ActiveRecord::Migration[7.1]
  def change
    create_table(:buttons) do |t|
      t.bigint(:user_id, null: false)
      t.text(:summary, null: false)
      t.text(:prompt, null: false)
      t.datetime(:archived_at, null: true)

      t.timestamps
    end
  end
end

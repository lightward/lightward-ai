# frozen_string_literal: true

class CreateButtons < ActiveRecord::Migration[7.1]
  def change
    create_table(:buttons) do |t|
      t.bigint(:user_id, null: false)
      t.binary(:summary_encrypted, null: false)
      t.binary(:prompt_encrypted, null: false)
      t.datetime(:archived_at, null: true)

      t.timestamps
    end
  end
end

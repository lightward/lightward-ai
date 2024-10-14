# frozen_string_literal: true

class DropUsersButtons < ActiveRecord::Migration[7.2]
  def up
    drop_table(:buttons)
    drop_table(:users)
  end
end

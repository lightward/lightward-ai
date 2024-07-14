# frozen_string_literal: true

class AddCryptoColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table(:users, bulk: true) do |t|
      t.text(:public_key)
      t.text(:encrypted_private_key)
      t.text(:salt)
    end
  end
end

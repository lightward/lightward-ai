# frozen_string_literal: true

class AddCryptoColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table(:users, bulk: true) do |t|
      t.binary(:public_key)
      t.binary(:private_key_encrypted)
      t.binary(:salt)
    end
  end
end

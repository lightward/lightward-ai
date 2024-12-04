# frozen_string_literal: true

class UserCleanup < ActiveRecord::Migration[8.0]
  def change
    change_table(:users, bulk: true) do |t|
      t.remove(:subscription_price_usd, type: :integer)
      t.remove(:subscription_started_at, type: :datetime)
      t.remove(:suspended_at, type: :datetime)
      t.remove(:suspended_for, type: :text)
      t.remove(:trial_expires_at, type: :datetime)
      t.remove(:updated_at, type: :datetime)
    end
  end
end

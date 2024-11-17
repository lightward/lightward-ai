# frozen_string_literal: true

class AddSubscriptionColumns < ActiveRecord::Migration[8.0]
  def change
    change_table(:users, bulk: true) do |t|
      t.datetime(:trial_expires_at, null: false, default: -> { "CURRENT_TIMESTAMP + INTERVAL '15 days'" })
      t.datetime(:suspended_at, null: true)
      t.text(:suspended_for, null: true)
      t.integer(:subscription_price_usd, default: 100, null: false)
      t.datetime(:subscription_started_at, null: true)

      t.text(:stripe_customer_id, null: true)
      t.text(:stripe_subscription_id, null: true)

      t.index(:stripe_customer_id, unique: true)
      t.index(:stripe_subscription_id, unique: true)
    end
  end
end

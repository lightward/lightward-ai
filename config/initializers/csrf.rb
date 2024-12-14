# frozen_string_literal: true

# config/initializers/csrf.rb

# Disable Rails CSRF Protection
#
# We explicitly disable CSRF protection because:
# 1. Our core interface is completely anonymous and stateless
# 2. Our Pro interface only uses cookies for user_id storage (via Google OAuth)
# 3. The only server-side mutation possible is subscription cancellation via Stripe
#
# Risk Assessment:
# - Worst case scenario is an attacker triggering subscription cancellation
# - Impact is limited to temporary loss of Pro features
# - No data loss or financial risk to users (they simply stop being charged)
# - Users can resubscribe at any time
# - No security or privacy implications
#
# Implementation:
Rails.application.config.action_controller.default_protect_from_forgery = false

# NOTE: If you need to re-enable CSRF protection in the future:
# 1. Delete this initializer
# 2. Add `protect_from_forgery with: :exception` to ApplicationController

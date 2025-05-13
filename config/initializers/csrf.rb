# frozen_string_literal: true

# config/initializers/csrf.rb

# We explicitly disable CSRF protection because this app is completely anonymous and stateless
Rails.application.config.action_controller.default_protect_from_forgery = false

# NOTE: If you need to re-enable CSRF protection in the future:
# 1. Delete this initializer
# 2. Add `protect_from_forgery with: :exception` to ApplicationController

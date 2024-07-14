# frozen_string_literal: true

class CryptoButtons < ActiveRecord::Migration[7.1]
  def up
    Button.includes(:user).find_each do |button|
      button.update!(
        summary: button.user.encrypt(button.summary),
        prompt: button.user.encrypt(button.prompt),
      )
    end

    rename_column(:buttons, :summary, :summary_encrypted)
    rename_column(:buttons, :prompt, :prompt_encrypted)
  end
end

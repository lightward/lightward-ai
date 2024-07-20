# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :user

  validates :data_encrypted, presence: true
end

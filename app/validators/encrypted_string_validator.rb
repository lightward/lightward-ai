# frozen_string_literal: true

# app/validators/encrypted_string_validator.rb
class EncryptedStringValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    begin
      Base64.strict_decode64(value)
    rescue ArgumentError
      record.errors.add(attribute, "must be a valid base64 encoded string")
    end
  end
end

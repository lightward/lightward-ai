# frozen_string_literal: true

# app/validators/base64_salt_validator.rb
class Base64SaltValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    begin
      decoded = Base64.strict_decode64(value)
      unless decoded.bytesize == 16
        record.errors.add(attribute, "must be a base64 encoded string of size 16")
      end
    rescue ArgumentError
      record.errors.add(attribute, "must be a valid base64 encoded string")
    end
  end
end

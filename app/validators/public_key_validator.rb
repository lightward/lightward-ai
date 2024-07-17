# frozen_string_literal: true

# app/validators/public_key_validator.rb
class PublicKeyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    begin
      OpenSSL::PKey::RSA.new(value)
    rescue OpenSSL::PKey::RSAError
      record.errors.add(attribute, "must be a valid RSA public key")
    end
  end
end

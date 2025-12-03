# frozen_string_literal: true

# Utility module for basic email operations
# Note: Email verification is primarily done via Hunter API
#
# @example
#   Qualifier::EmailPatterns.extract_domain("john@stripe.com")
#   # => "stripe.com"
#
#   Qualifier::EmailPatterns.valid_format?("john@stripe.com")
#   # => true
#
module Qualifier::EmailPatterns
  # Extracts domain from an email address
  #
  # @param [String] email The email address
  # @return [String, nil] The domain part or nil if invalid
  def self.extract_domain(email)
    return nil if email.blank?
    return nil unless email.include?("@")

    email.strip.downcase.split("@").last
  end

  # Validates basic email format
  #
  # @param [String] email The email address
  # @return [Boolean] True if valid format, false otherwise
  def self.valid_format?(email)
    return false if email.blank?

    email.strip.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
  end
end


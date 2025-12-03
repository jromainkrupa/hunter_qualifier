# frozen_string_literal: true

require "test_helper"

class Qualifier::EmailPatternsTest < ActiveSupport::TestCase
  test "extract_domain returns domain from valid email" do
    assert_equal "world.com", Qualifier::EmailPatterns.extract_domain("hello@world.com")
  end

  test "extract_domain returns domain from email with UK TLD" do
    assert_equal "word.co.uk", Qualifier::EmailPatterns.extract_domain("hello@word.co.uk")
  end

  test "extract_domain returns nil for invalid email without @" do
    assert_nil Qualifier::EmailPatterns.extract_domain("hello.com")
  end

  test "extract_domain returns nil for nil input" do
    assert_nil Qualifier::EmailPatterns.extract_domain(nil)
  end

  test "extract_domain returns nil for empty string" do
    assert_nil Qualifier::EmailPatterns.extract_domain("")
  end

  test "extract_domain normalizes to lowercase" do
    assert_equal "stripe.com", Qualifier::EmailPatterns.extract_domain("John@Stripe.COM")
  end

  test "extract_domain handles emails with spaces" do
    assert_equal "example.com", Qualifier::EmailPatterns.extract_domain("  test@example.com  ")
  end

  test "valid_format? returns true for standard email" do
    assert Qualifier::EmailPatterns.valid_format?("hello@world.com")
  end

  test "valid_format? returns true for email with UK TLD" do
    assert Qualifier::EmailPatterns.valid_format?("hello@word.co.uk")
  end

  test "valid_format? returns false for string without @" do
    assert_not Qualifier::EmailPatterns.valid_format?("hello.com")
  end

  test "valid_format? returns false for nil input" do
    assert_not Qualifier::EmailPatterns.valid_format?(nil)
  end

  test "valid_format? returns false for empty string" do
    assert_not Qualifier::EmailPatterns.valid_format?("")
  end

  test "valid_format? returns false for email without domain" do
    assert_not Qualifier::EmailPatterns.valid_format?("hello@")
  end

  test "valid_format? returns false for email without local part" do
    assert_not Qualifier::EmailPatterns.valid_format?("@domain.com")
  end

  test "valid_format? returns true for complex corporate email" do
    assert Qualifier::EmailPatterns.valid_format?("john.doe+test@company.co.uk")
  end
end


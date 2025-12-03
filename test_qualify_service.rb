#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Qualifier::QualifyUserService
# Run with: ruby test_qualify_service.rb

require_relative "config/environment"

def test_qualification(email:, location: nil, signup_source: nil)
  puts "\n" + "=" * 80
  puts "Testing: #{email}"
  puts "Location: #{location || 'N/A'}"
  puts "Signup Source: #{signup_source || 'N/A'}"
  puts "-" * 80

  service = Qualifier::QualifyUserService.new(
    email: email,
    location: location,
    signup_source: signup_source
  )

  start_time = Time.now
  result = service.run
  elapsed = Time.now - start_time

  puts "\nResult:"
  puts "  Bucket: #{result[:bucket]}"
  puts "  Explanations:"
  result[:explanation].each do |explanation|
    puts "    - #{explanation}"
  end
  puts "\n  Time: #{elapsed.round(2)}s"
  
  # Show logs if in development
  if Rails.env.development?
    puts "\n  Check log/development.log for detailed API responses"
  end
  
  puts "=" * 80

  result
rescue => e
  puts "\n❌ ERROR: #{e.class} - #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts "=" * 80
  nil
end

# Test scenarios
puts "\n🧪 Testing Qualifier::QualifyUserService"
puts "=" * 80

# Test 1: sales@hunter.io (nothing else)
test_qualification(email: "sales@hunter.io")

# Test 2: jean@gmail.com (nothing else)
test_qualification(email: "jean@gmail.com")

# Test 3: bastien@hunter.io, location nigeria
test_qualification(email: "bastien@hunter.io", location: "nigeria")

# Test 4: bastien@hunter.io, location france
test_qualification(email: "bastien@hunter.io", location: "france")

# Test 5: bastien@hunter.io, refer appsumo
test_qualification(email: "bastien@hunter.io", signup_source: "appsumo")

# Test 6: Salesforce CEO
test_qualification(email: "marc.benioff@salesforce.com")

puts "\n✅ All tests completed!"
puts "=" * 80


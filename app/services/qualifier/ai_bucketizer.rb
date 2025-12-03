# frozen_string_literal: true

# Service for bucketizing users into qualification segments using AI analysis
#
# @example
#   data = { person: {...}, company: {...}, meta: {...} }
#   result = Qualifier::AiBucketizer.bucketize(data, signup_source: "google.com", location: "US")
#   # => { bucket: "high_potential", explanation: ["Large company", "Tech industry", "Location verified"] }
#
module Qualifier::AiBucketizer
  # Analyzes enrichment data and assigns user to a qualification bucket
  #
  # @param [Hash] data The enrichment data from Hunter API
  # @param [Hash] options Additional context for analysis
  # @option options [String] :signup_source The referrer page or signup source
  # @option options [String] :location User's location/country code
  # @return [Hash] The qualification result with bucket and explanation
  #   @option result [String] :bucket The assigned bucket name
  #   @option result [Array<String>] :explanation List of reasons for the qualification
  def self.bucketize(data, options = {})
    return error_result("No enrichment data provided") if data.nil?

    filtered_data = filter_enrichment_data(data)
    prompt = build_prompt(filtered_data, options)
    
    response = OpenaiClient.new.call(messages: prompt)
    
    return error_result("AI analysis failed") if response.nil?
    
    parse_and_validate_response(response)
  rescue => e
    Rails.logger.error("AiBucketizer failed: #{e.class} - #{e.message}")
    error_result("AI analysis error: #{e.message}")
  end

  private

  # Filters out unnecessary fields from enrichment data
  #
  # @param [Hash, Object] data The raw enrichment data (may be hash or object)
  # @return [Hash] Filtered enrichment data as hash
  def self.filter_enrichment_data(data)
    # Convert to hash if it's an object (like ActiveSupport::InheritableOptions)
    hash_data = if data.respond_to?(:to_h)
      data.to_h.deep_stringify_keys
    elsif data.is_a?(Hash)
      data.deep_stringify_keys
    else
      data
    end
    
    # Create a deep copy to avoid mutating original
    filtered = JSON.parse(hash_data.to_json)
    
    # Remove email addresses and phone numbers from company site
    if filtered["company"] && filtered["company"]["site"]
      filtered["company"]["site"].delete("emailAddresses")
      filtered["company"]["site"].delete("phoneNumbers")
    end
    
    # Remove tech and techCategories arrays
    if filtered["company"]
      filtered["company"].delete("tech")
      filtered["company"].delete("techCategories")
    end
    
    filtered
  end

  # Builds the prompt for OpenAI API
  #
  # @param [Hash] filtered_data The filtered enrichment data
  # @param [Hash] options Additional context (signup_source, location)
  # @return [Array<Hash>] Array of message hashes for OpenAI API
  def self.build_prompt(filtered_data, options = {})
    signup_source = options[:signup_source]
    location = options[:location]

    system_message = <<~PROMPT
      You are an expert at analyzing companies and individuals to determine their likelihood of purchasing Hunter.io, an email finder and verification service used for sales outreach and lead generation.

      Analyze the provided company and person data to determine:
      1. How likely they are to purchase Hunter.io (score 0-100)
      2. Which qualification bucket they belong to: enterprise, high_potential, or not_likely_to_buy
      3. Short explanations (2-4 items) for your decision

      Consider these factors:
      - Company size (employee count, revenue indicators)
      - Industry and sector
      - Person's role and seniority
      - Company type (public, private, startup)
      - Geographic location (verify if provided user location matches company location)
      - Company description and business model
      - Signup source/referrer (if provided, consider if it indicates legitimate interest)

      IMPORTANT: If a user location is provided, verify that it matches the company's geographic location. Location mismatches may indicate suspicious signups.

      Bucket definitions:
      - enterprise: Large companies (typically 1000+ employees) with significant sales/outreach needs
      - high_potential: Mid-sized companies (typically 50-1000 employees) with growth potential and sales needs
      - not_likely_to_buy: Small companies, non-profits, or companies unlikely to need email finding/verification services

      Respond ONLY with valid JSON in this exact format:
      {
        "score": <0-100 integer>,
        "bucket": "<enterprise|high_potential|not_likely_to_buy>",
        "explanations": ["<short explanation 1>", "<short explanation 2>", ...]
      }
    PROMPT

    user_message_parts = ["Analyze this company and person data:"]
    user_message_parts << "\n#{filtered_data.to_json}"
    
    if location.present?
      user_message_parts << "\n\nUser provided location: #{location}"
      user_message_parts << "Please verify if this location matches the company's geographic location from the data above."
    end
    
    if signup_source.present?
      user_message_parts << "\n\nSignup source/referrer: #{signup_source}"
    end

    [
      { role: "system", content: system_message.strip },
      { role: "user", content: user_message_parts.join("\n") }
    ]
  end

  # Parses and validates the OpenAI response
  #
  # @param [Hash] response The parsed JSON response from OpenAI
  # @return [Hash] The qualification result
  def self.parse_and_validate_response(response)
    score = response["score"] || response[:score]
    bucket = response["bucket"] || response[:bucket]
    explanations = response["explanations"] || response[:explanations] || []

    # Validate bucket is one of the allowed values
    valid_buckets = %w[enterprise high_potential not_likely_to_buy]
    bucket = "needs_review" unless valid_buckets.include?(bucket.to_s)

    # Ensure explanations is an array
    explanations = Array(explanations)

    # Validate score is in range
    score = score.to_i
    score = 0 if score < 0
    score = 100 if score > 100

    {
      bucket: bucket.to_s,
      explanation: explanations.map(&:to_s)
    }
  rescue => e
    Rails.logger.error("Failed to parse AI response: #{e.class} - #{e.message}")
    error_result("Invalid AI response format")
  end

  # Returns an error result
  #
  # @param [String] message The error message
  # @return [Hash] Error result
  def self.error_result(message)
    {
      bucket: "needs_review",
      explanation: [message]
    }
  end
end
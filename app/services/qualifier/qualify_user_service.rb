# frozen_string_literal: true

# Service for qualifying new users into segments based on email and enrichment data
#
# @example
#   service = Qualifier::QualifyUserService.new(
#     email: "john@stripe.com",
#     location: "US"
#   )
#   result = service.run
#   # => { bucket: "high_potential", explanation: ["Corporate email domain", "Mid-sized company"] }
#
class Qualifier::QualifyUserService
  # Initialize the service with user signup attributes
  #
  # @param [Hash] attributes The user signup attributes
  # @option attributes [String] :email User's email address (required)
  # @option attributes [String] :first_name User's first name
  # @option attributes [String] :last_name User's last name
  # @option attributes [String] :location User's location/country code
  # @option attributes [String] :signup_source Referrer or signup source
  # @option attributes [String] :ip_address User's IP address
  def initialize(attributes)
    @email = attributes[:email]
    @first_name = attributes[:first_name]
    @last_name = attributes[:last_name]
    @location = attributes[:location]
    @signup_source = attributes[:signup_source]
    @ip_address = attributes[:ip_address]
    @explanations = []
    @hunter_client = HunterClient.client
  end

  # Runs the service to qualify the user into a bucket
  #
  # @return [Hash] The qualification result with bucket and explanation
  #   @option result [String] :bucket The assigned bucket name
  #   @option result [Array<String>] :explanation List of reasons for the qualification
  def run
    return invalid_email_result unless Qualifier::EmailPatterns.valid_format?(@email)

    # Verify email with Hunter API
    verification_data = verify_email(@email)
    
    # Handle verification results
    keep_running, result = handle_verification_result(verification_data)
    return result unless keep_running
    
    # Combined enrichment for the email (Hunter API requires full email, not just domain)
    enrichment_data = combined_enrichment(@email)
    handle_enrichment_result(enrichment_data)
  end

  private

  # Returns result for invalid email
  #
  # @return [Hash] Qualification result
  def invalid_email_result
    {
      bucket: "needs_review",
      explanation: ["Invalid email format"]
    }
  end

  # Verifies email using Hunter Email Verifier API
  def verify_email(email)
    response = @hunter_client.email_verifier(email: email)
    response.parsed_body.data
  rescue => e
    Rails.logger.info("Hunter Email Verifier failed for #{email}: #{e.class} - #{e.message}")
    nil
  end

  # Handles verification result from Hunter API
  # Immediately reject disposable emails
  def handle_verification_result(data)
    if data.disposable
      @explanations << "Disposable email address"
      @explanations << "Temporary email service"
      return false,{ bucket: "not_likely_to_buy", explanation: @explanations }
    end

    # Immediately reject webmail providers
    if data.webmail
      @explanations << "Personal email address"
      @explanations << "Webmail provider"
      return false, { bucket: "not_likely_to_buy", explanation: @explanations }
    end

    @explanations << "Verified email address (score: #{data.score})" if data.score

    return true, { bucket: nil, explanation: @explanations }
  end


  # Fetches enrichment data from Hunter API
  def combined_enrichment(email)
    response = @hunter_client.combined_enrichment(email: email)
    response.parsed_body.data
  rescue => e
    Rails.logger.info("Hunter API failed for #{email}: #{e.class} - #{e.message}")
    nil
  end

  def handle_enrichment_result(data)
    return {
      bucket: "needs_review",
      explanation: @explanations + ["No enrichment data available"]
    } if data.nil?

    result = Qualifier::AiBucketizer.bucketize(
      data,
      signup_source: @signup_source,
      location: @location
    )
    
    # Merge any existing explanations with AI explanations
    if result[:explanation].is_a?(Array)
      @explanations.concat(result[:explanation])
    end
    
    {
      bucket: result[:bucket],
      explanation: @explanations.uniq
    }
  end
end


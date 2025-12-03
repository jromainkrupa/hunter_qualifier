class HunterClient < ApplicationClient
  BASE_URI = "https://api.hunter.io/v2"

  def self.client
    new(token: Rails.application.credentials.dig(:hunter, :api_key))
  end

  def self.client_for(connected_account)
    new(auth: connected_account)
  end

  def authorization_header
    key = token || Rails.application.credentials.dig(:hunter, :api_key)
    {"X-API-KEY" => key}.compact
  end

  # https://hunter.io/api-documentation/v2#email-verifier
  def email_verifier(email:)
    get "/email-verifier", query: {email: email}
  end

  # https://hunter.io/api-documentation/v2#combined-enrichment
  def combined_enrichment(email: nil)
    get "/combined/find", query: {email: email}
  end

end

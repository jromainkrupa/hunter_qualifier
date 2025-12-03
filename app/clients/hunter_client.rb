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

  def domain_search(domain: nil, company: nil, email_type: nil, seniority: nil, department: nil, limit: nil, offset: nil)
    email_type = (email_type == "all") ? nil : email_type
    seniority  = (seniority == "all") ? nil : seniority
    department = (department == "all") ? nil : department

    query = {
      domain: domain ? domain : nil,
      company: company,
      type: email_type,
      seniority: seniority,
      department: department,
      limit: limit,
      offset: offset
    }.compact_blank

    get "/domain-search", query: query
  end

  def email_finder(domain: nil, company: nil, first_name: nil, last_name: nil, full_name: nil)
    query = {
      domain: domain ? domain : nil,
      company: company,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name
    }.compact
    get "/email-finder", query: query
  end

  def email_verifier(email:)
    get "/email-verifier", query: {email: email}
  end

  def company_enrichment(domain:)
    get "/enrichment", query: {domain: domain}
  end
end

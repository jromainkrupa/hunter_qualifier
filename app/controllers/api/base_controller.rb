class Api::BaseController < ActionController::API
  include ActionController::Caching

  prepend_before_action :require_api_authentication

  private

  def require_api_authentication
    expected_token = api_token
    return if token_from_header == expected_token
    
    head :unauthorized
  end

  def api_token
   Rails.application.credentials.dig(:test, :api_token)
  end

  def token_from_header
    request.headers.fetch("Authorization", "").split(" ").last
  end
end

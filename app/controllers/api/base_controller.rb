class Api::BaseController < ActionController::API
  include ActionController::Caching

  prepend_before_action :require_api_authentication

  private

  def require_api_authentication
    return if token_from_header == Rails.application.credentials.dig(:test, :api_token)
    
    head :unauthorized
  end

  def token_from_header
    request.headers.fetch("Authorization", "").split(" ").last
  end
end

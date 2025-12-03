# frozen_string_literal: true

class Api::V1::QualificationsController < Api::BaseController
  rate_limit to: 10, within: 1.minute, by: -> { request.remote_ip }

  # POST /api/v1/qualifications
  def create
    service = Qualifier::QualifyUserService.new(qualification_params)
    result = service.run

    render json: result, status: :ok
  rescue => e
    Rails.logger.error("Qualification failed: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    render json: {
      bucket: "needs_review",
      explanation: ["Service temporarily unavailable"]
    }, status: :service_unavailable
  end

  private

  def qualification_params
    params.expect(
      qualification: [
        :email,
        :first_name,
        :last_name,
        :password,
        :signup_source,
        :location,
        :ip_address
      ]
    )
  end
end


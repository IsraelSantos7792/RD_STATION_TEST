class ApplicationController < ActionController::API
  rescue_from StandardError, with: :render_internal_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
  rescue_from ActionController::UnpermittedParameters, with: :render_parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ApplicationError, with: :render_application_error

  private

  def render_not_found(exception)
    render json: { error: "Resource not found", detail: exception.message }, status: :not_found
  end

  def render_parameter_missing(exception)
    render json: { error: "Invalid request", detail: exception.message }, status: :unprocessable_entity
  end

  def render_record_invalid(exception)
    render json: {
      error: "Validation failed",
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_application_error(exception)
    render json: { error: exception.message }, status: exception.http_status
  end

  def render_internal_server_error(exception)
    raise exception if Rails.env.local?

    Rails.logger.error(
      event: "unhandled_exception",
      exception: exception.class.name,
      message: exception.message
    )
    render json: { error: "Internal server error" }, status: :internal_server_error
  end
end

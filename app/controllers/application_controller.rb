class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :handle_internal_server_error

  private

  def handle_internal_server_error
    render json: { error: 'Something went wrong.' }, status: :internal_server_error
  end
end

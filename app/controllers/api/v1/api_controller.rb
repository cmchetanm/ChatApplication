# frozen_string_literal: true

# app/controllers/api/v1/api_controller.rb

class Api::V1::ApiController < ActionController::API
  include ApplicationMethods

  attr_reader :current_user

  before_action :authenticate_request

  private

  def authenticate_request
    auth = AuthorizeApiRequest.call(request.headers)
    @current_user = auth.result
    render_unauthorized_response(auth.errors) and return unless @current_user
  end

end

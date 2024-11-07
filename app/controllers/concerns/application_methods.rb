# frozen_string_literal: true

module ApplicationMethods
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    around_action :handle_exceptions
  end

  private

  # Catch exception and return JSON-formatted error
  def handle_exceptions
    begin
      yield
    rescue ActiveRecord::RecordNotFound => e
      @status = 404
    rescue ActiveRecord::RecordInvalid => e
      render_unprocessable_entity_response(e.record) && return
    rescue ActionController::ParameterMissing => e
      @status = 422
    rescue ArgumentError => e
      @status = 400
    rescue StandardError => e
      @status = 500
    end
    detail = { detail: e.try(:message) }
    detail.merge!(trace: e.try(:backtrace))
    json_response({ success: false, message: e.class.to_s, errors: [detail] }, @status) unless e.instance_of?(NilClass)
  end

  def render_unprocessable_entity_response(resource)
    json_response({
                    success: false,
                    message: 'Validation failed',
                    errors: ValidationErrorsSerializer.new(resource).serialize
                  }, 422)
  end

  def render_unprocessable_entity(message)
    json_response({
                    success: false,
                    errors: [message]
                  }, 422) and return true
  end

  def render_success_response(resources = {}, message = '', status = 200, meta = {})
    json_response({
                    success: true,
                    message:,
                    data: resources,
                    meta:
                  }, status)
  end

  def json_response(options = {}, status = 500)
    render json: JsonResponse.new(options), status:
  end

  def render_unauthorized_response(message = {})
    token_expired = message[:token] == ['Token has expired']
    json_response({
                    success: false,
                    message: 'You are not authorized.',
                    errors: [message, { token_expired: }]
                  }, 401)
  end

  def single_serializer
    ActiveModelSerializers::SerializableResource
  end
end

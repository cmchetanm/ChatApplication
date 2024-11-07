class AuthorizeApiRequest < ApplicationService
  attr_reader :headers

  def initialize(headers = {})
    @headers = headers
  end

  def call
    handle_request
  end

  private

  def user
    @user ||= @decoded_auth_token[:user_type].constantize.find(@decoded_auth_token[:user_id])
    # @user || errors.add(:token, 'Token has expired') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def handle_request
    response = decoded_auth_token
    case response
    when "token expired"
      errors.add(:token, 'Token has expired')
    when nil
      errors.add(:token, 'Invalid token')
    else
      user
    end
  end
  def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    else
      errors.add(:token, 'missing token')
    end
    nil
  end
end

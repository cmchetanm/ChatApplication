module AuthHelper
  def generate_jwt(user, user_type = 'User')
    payload = { user_id: user.id, user_type: user_type }
    JsonWebToken.encode(payload)
  end

  def set_authorization_header(user, user_type = 'User')
    token = generate_jwt(user, user_type)
    request.headers['Authorization'] = "Bearer #{token}"
  end
end
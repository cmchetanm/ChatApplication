class AuthenticateUser < ApplicationService

  attr_accessor :email, :password, :user

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    return unless authenticate_user.present?
    
    { token: JsonWebToken.encode(user_id: user.id, user_type: 'User') }
  end
  private

  def authenticate_user
    @user = User.find_by(email: email)
    if user.present?
      if user&.authenticate(password)
        return user
      else
        errors.add :user_authentication, I18n.t('errors.invalid_credentials')
      end
    else
      errors.add :user_authentication, I18n.t('errors.account_not_found')
    end
  end
end

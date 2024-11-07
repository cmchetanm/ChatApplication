# spec/services/authenticate_user_spec.rb
require 'rails_helper'

RSpec.describe AuthenticateUser do
  let(:user) { create(:user, email: 'test@example.com', password: 'password') }

  describe '#call' do
    context 'when the credentials are valid' do
      it 'returns a JWT token' do
        service = AuthenticateUser.new(user.email, 'password')
        result = service.call

        expect(result).to be_a(Hash)
        expect(result[:token]).not_to be_nil
        decoded_token = JsonWebToken.decode(result[:token])
        expect(decoded_token[:user_id]).to eq(user.id)
        expect(decoded_token[:user_type]).to eq('User')
      end
    end

    context 'when the password is incorrect' do
      it 'adds an invalid credentials error' do
        service = AuthenticateUser.new(user.email, 'wrong_password')
        result = service.call

        expect(result).to be_nil
        expect(service.errors[:user_authentication]).to include(I18n.t('errors.invalid_credentials'))
      end
    end

    context 'when the user is not found' do
      it 'adds an account not found error' do
        service = AuthenticateUser.new('nonexistent@example.com', 'password')
        result = service.call

        expect(result).to be_nil
        expect(service.errors[:user_authentication]).to include(I18n.t('errors.account_not_found'))
      end
    end
  end
end

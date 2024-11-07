require 'rails_helper'

RSpec.describe Api::V1::Users::RegistrationsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_params) { { full_name: 'John Doe', email: 'john@example.com', password: 'password123' } }

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns success response with token' do
        post :create, params: valid_params
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid parameters' do
      it 'returns error when email is missing' do
        post :create, params: valid_params.except(:email)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error with invalid parameters' do
        post :create, params: { email: 'invalid', password: 'short', full_name: '' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #password_reset' do
    before do
      set_authorization_header(user)
    end

    it 'updates user password successfully' do
      post :password_reset, params: { password: 'newpassword123' }
      expect(response).to have_http_status(:success)
      expect(user.reload.authenticate('newpassword123')).to be_truthy
    end
  end

  describe 'GET #check_status' do
    context 'when user exists' do
      it 'returns user status' do
        get :check_status, params: { id: user.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user does not exist' do
      it 'returns error message' do
        get :check_status, params: { id: -1 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

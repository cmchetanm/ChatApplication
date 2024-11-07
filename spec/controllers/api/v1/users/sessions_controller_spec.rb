require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123', status: 'offline') }

  describe 'POST #create' do
    let(:valid_params) { { email: user.email, password: 'password123' } }
    let(:invalid_params) { { email: user.email, password: 'wrong_password' } }

    context 'with valid credentials' do
      before do
        allow(AuthenticateUser).to receive(:call).and_return(
          double(success?: true, result: 'auth_token')
        )
        post :create, params: valid_params
      end

      it 'returns success response' do
        expect(response).to have_http_status(:success)
      end

      it 'updates user status to online' do
        user.reload
        expect(user.status).to eq('online')
      end
    end

    context 'with invalid credentials' do
      before do
        allow(AuthenticateUser).to receive(:call).and_return(
          double(success?: false, errors: ['Invalid credentials'])
        )
        post :create, params: invalid_params
      end

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #logout' do

    before do
      allow(controller).to receive(:current_user).and_return(user)
      set_authorization_header(user)
    end

    it 'updates user status to offline' do
      post :logout
      user.reload
      expect(user.status).to eq('offline')
    end

    it 'returns success response' do
      post :logout
      expect(response).to have_http_status(:success)
    end

    context 'when no authorization header is present' do
      before do
        request.headers['Authorization'] = nil
        post :logout
      end
    end
  end
end

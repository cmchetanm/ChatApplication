require 'rails_helper'

RSpec.describe AuthorizeApiRequest do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id, user_type: user.class.name) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  
  subject(:auth_request) { described_class.new(headers) }

  describe '#call' do
    context 'with valid token' do
      it 'returns the user' do
        result = auth_request.call
        expect(result).to eq(user)
      end
    end

    context 'with expired token' do
      before do
        allow(JsonWebToken).to receive(:decode).and_return("token expired")
      end

      it 'adds token expired error' do
        result = auth_request.call
        expect(auth_request.errors[:token]).to include('Token has expired')
      end
    end

    context 'with invalid token' do
      before do
        allow(JsonWebToken).to receive(:decode).and_return(nil)
      end

      it 'adds invalid token error' do
        result = auth_request.call
        expect(auth_request.errors[:token]).to include('Invalid token')
      end
    end

    context 'when authorization header is missing' do
      let(:headers) { {} }

      it 'adds missing token error' do
        result = auth_request.call
        expect(auth_request.errors[:token]).to include('missing token')
      end
    end

    context 'when user type is invalid' do
      let(:invalid_token) { JsonWebToken.encode(user_id: user.id, user_type: 'InvalidClass') }
      let(:headers) { { 'Authorization' => "Bearer #{invalid_token}" } }

      it 'raises name error for invalid constant' do
        expect { auth_request.call }.to raise_error(NameError)
      end
    end

    context 'when user id does not exist' do
      let(:non_existent_token) { JsonWebToken.encode(user_id: -1, user_type: 'User') }
      let(:headers) { { 'Authorization' => "Bearer #{non_existent_token}" } }

      it 'raises record not found error' do
        expect { auth_request.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

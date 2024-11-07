require 'rails_helper'

RSpec.describe Api::V1::Users::RegistrationSerializer do
  let(:user) { create(:user) }
  let(:serializer) { described_class.new(user) }

  describe '#serialized_json' do
    let(:serialized_user) { JSON.parse(serializer.to_json) }

    it 'has the correct values for all attributes' do
      expect(serialized_user['id']).to eq(user.id)
      expect(serialized_user['email']).to eq(user.email)
      expect(serialized_user['full_name']).to eq(user.full_name)
    end

    it 'handles empty string values' do
      user.full_name = ''
      expect(serialized_user['full_name']).to eq('')
    end

    it 'serializes user with special characters in attributes' do
      user.full_name = 'Test@User#123'
      expect(serialized_user['full_name']).to eq('Test@User#123')
    end
  end
end

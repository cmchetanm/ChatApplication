require 'rails_helper'

RSpec.describe Api::V1::MessageSerializer do
  let(:user) { create(:user, full_name: 'John Smith', status: 'online') }
  let(:chat_room) { create(:chat_room, member_ids: [user.id]) }
  let(:message) { create(:message, user: user, chat_room: chat_room, content: 'Test message') }
  let(:serializer) { described_class.new(message) }
  let(:serialization) { JSON.parse(serializer.to_json) }

  describe '#created_at' do
    it 'includes the created_at timestamp' do
      expect(serialization).to include('created_at')
      expect(serialization['created_at']).to eq(message.created_at.as_json)
    end
  end

  describe '#user attribute' do
    it 'returns the user full name' do
      expect(serialization['user']).to eq('John Smith')
    end
  end

  describe 'serializer structure' do
    it 'includes only the specified attributes' do
      expected_keys = ['id', 'content', 'created_at', 'user']
      expect(serialization.keys).to match_array(expected_keys)
    end
  end
end

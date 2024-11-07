require 'rails_helper'

RSpec.describe Api::V1::ChatRoomSerializer do
  let(:other_user1) { create(:user) }
  let(:other_user) { create(:user) }  
  let(:user) { create(:user, email: 'test@example.com', full_name: 'Test User') }
  let(:chat_room) { create(:chat_room, member_ids: [user, other_user.id, other_user1.id]) }
  let(:serializer) { described_class.new(chat_room) }

  before do
    chat_room.users << user
  end

  describe '#serialized_json' do
    let(:serialized_chat_room) { JSON.parse(serializer.to_json) }

    it 'includes the correct attributes' do
      expect(serialized_chat_room.keys).to match_array(['id', 'name', 'chat_room_type', 'users', 'messages'])
    end

    it 'has the correct values for basic attributes' do
      expect(serialized_chat_room['id']).to eq(chat_room.id)
      expect(serialized_chat_room['chat_room_type']).to eq('public_room')
    end

    it 'serializes users with correct attributes' do
      serialized_user = serialized_chat_room['users'].first
      expect(serialized_user['id']).to eq(user.id)
      expect(serialized_user['email']).to eq('test@example.com')
      expect(serialized_user['full_name']).to eq('Test User')
    end

    it 'handles multiple users correctly' do
      another_user = create(:user, email: 'another@example.com', full_name: 'Another User')
      chat_room.users << another_user

      expect(serialized_chat_room['users'].length).to eq(5)
    end

  end
end

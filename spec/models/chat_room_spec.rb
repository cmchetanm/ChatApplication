
require 'rails_helper'

RSpec.describe ChatRoom, type: :model do
  let(:user) { create(:user, full_name: 'John Doe') }
  let(:other_user) { create(:user, full_name: 'Jane Smith') }
  let(:third_user) { create(:user, full_name: 'Bob Wilson') }

  describe 'enums' do
    it { should define_enum_for(:chat_room_type).with_values(public_room: 0, private_room: 1) }
  end

  describe '#set_chat_room_name' do
    context 'when creating a private chat room with 2 users' do
      let(:chat_room) { build(:chat_room, current_user_id: user.id, member_ids: [other_user.id]) }

      it 'sets chat room type to private' do
        chat_room.save
        expect(chat_room.private_room?).to be true
      end

      it 'sets name as combination of user full names' do
        chat_room.save
        expect(chat_room.name).to eq("#{user.full_name}_#{other_user.full_name}")
      end
    end

    context 'when creating a chat room with more than 2 users' do
      let(:chat_room) { build(:chat_room, current_user_id: user.id, member_ids: [other_user.id, third_user.id]) }

      it 'does not modify the chat room type' do
        chat_room.name = 'Group Chat'
        chat_room.save
        expect(chat_room.public_room?).to be true
      end

      it 'preserves the original name' do
        original_name = 'Group Chat'
        chat_room.name = original_name
        chat_room.save
        expect(chat_room.name).to eq(original_name)
      end
    end
  end

  describe '#name_for_private_room' do
    let(:chat_room) { create(:chat_room, current_user_id: user.id, member_ids: [other_user.id]) }

    it 'prevents name updates for private rooms' do
      chat_room.name = 'New Name'
      chat_room.valid?
      expect(chat_room.errors[:base]).to include(I18n.t('chat_room.name_update'))
    end
  end

  describe '#member_ids=' do
    let(:chat_room) { build(:chat_room, current_user_id: user.id) }

    it 'adds current user to member list' do
      chat_room.member_ids = [other_user.id, third_user.id]
      expect(chat_room.users).to include(user)
    end

    it 'sets all specified members' do
      chat_room.member_ids = [other_user.id, third_user.id]
      expect(chat_room.users).to match_array([user, other_user, third_user])
    end

    it 'handles empty member list' do
      chat_room.member_ids = []
      expect(chat_room.users).to match_array([user])
    end
  end
end

require 'rails_helper'

RSpec.describe ChatRoomMembership, type: :model do
  let(:user) { create(:user) }
  let(:other_user1) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:chat_room) { create(:chat_room, member_ids: [other_user.id, other_user1.id, user]) }

  let(:membership) { build(:chat_room_membership, user: user, chat_room: chat_room) }

  describe 'associations' do
    
    it { should belong_to(:user) }
    it { should belong_to(:chat_room) }
  end

  describe '#user_count' do
    context 'when chat room is public' do
      before do
        allow(chat_room).to receive(:public_room?).and_return(true)
      end

      it 'allows membership creation' do
        expect(membership).to be_valid
      end
    end

    context 'when chat room is private' do
      before do
        allow(chat_room).to receive(:public_room?).and_return(false)
      end

      context 'with less than 2 users' do
        before do
          allow(chat_room).to receive(:users).and_return([])
        end

        it 'allows membership creation' do
          expect(membership).to be_valid
        end
      end

      context 'with 2 or more users' do
        before do
          allow(chat_room).to receive(:users).and_return([create(:user), create(:user)])
        end

        it 'prevents membership creation' do
          expect(membership).not_to be_valid
          expect(membership.errors[:errors]).to include(I18n.t('chat_room.private_room_error'))
        end
      end
    end
  end
end

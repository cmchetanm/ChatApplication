require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  let(:other_user1) { create(:user) }
  let(:other_user) { create(:user) }  
  let(:user) { create(:user) }
  let(:chat_room) { create(:chat_room, member_ids: [user, other_user.id, other_user1.id]) }

  before do
    set_authorization_header(user)
  end

  describe 'POST #create' do
    context 'when user is a member of the chat room' do
      it 'creates a new message successfully' do
        post :create, params: { 
          chat_room_id: chat_room.id, 
          message: { content: 'Hello World' } 
        }
        expect(response).to have_http_status(:success)
        expect(chat_room.messages.last.content).to eq('Hello World')
      end

      it 'returns error for empty content' do
        post :create, params: { 
          chat_room_id: chat_room.id, 
          message: { content: '' } 
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

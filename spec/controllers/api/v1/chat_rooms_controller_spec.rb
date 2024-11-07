require 'rails_helper'

RSpec.describe Api::V1::ChatRoomsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:other_user1) { create(:user) }
  let(:other_user2) { create(:user) }
  let!(:chat_room) { create(:chat_room, member_ids: [other_user.id, other_user1.id, user]) }
  let(:valid_attributes) { { name: 'Test Room', member_ids: [other_user.id, user] } }
  
  before do
    set_authorization_header(user)
  end

  describe 'POST #create' do
    
    context 'with valid parameters' do      
      it 'creates a new chat room if member is added ' do
        post :create, params: { chat_room: valid_attributes }
        expect(JSON.parse(response.body)['message']).to eq('Chat room created successfully')
      end
    end

    context 'with invalid parameters' do
      before do
        valid_attributes[:name] = ''
      end
      it 'creates a new chat room if member is added ' do
        post :create, params: { chat_room: valid_attributes }
        expect(JSON.parse(response.body)['message']).to eq('Validation failed')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      it 'updates a chat room' do
        put :update, params: { id: chat_room.id, chat_room: valid_attributes }
        expect(JSON.parse(response.body)['message']).to eq('Chat room updated successfully')
      end

      context 'add members to chat room' do
        before do
          valid_attributes[:member_ids] = [user, other_user.id, other_user1.id, other_user2.id]
        end
        it 'adds member' do
          put :update, params: { id: chat_room.id, chat_room: valid_attributes }
          expect(JSON.parse(response.body)["data"]["chat_room"]["users"].count).to eq(4)
        end
      end

      context 'remove members from chat room' do
        before do
          valid_attributes[:member_ids] = [other_user.id]
        end
        it 'removes member' do
          put :update, params: { id: chat_room.id, chat_room: valid_attributes }
          expect(JSON.parse(response.body)["data"]["chat_room"]["users"].count).to eq(2)
        end
      end
    end
    
    context 'with invalid parameters' do
      it 'returns unprocessable entity status' do
        put :update, params: { id: chat_room.id, chat_room: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid parameters' do
      it 'deletes a chat room' do
        delete :destroy, params: { id: chat_room.id }
        expect(JSON.parse(response.body)['message']).to eq('Chat room deleted successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity when id is not passed' do
        delete :destroy, params: { id: '' }
        expect(JSON.parse(response.body)['message']).to eq("ActiveRecord::RecordNotFound")
      end
    end

    context 'when destroy fails' do
      before do
        allow(ChatRoom).to receive(:find).and_return(chat_room)
        allow(chat_room).to receive(:destroy).and_return(false)
      end
      it 'returns an unprocessable entity response' do
        delete :destroy, params: { id: chat_room.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #show' do
    context 'with valid parameters' do
      it 'displays a chat room' do
        get :show, params: { id: chat_room.id }
        expect(response).to have_http_status(200)
      end
    end
  end
end


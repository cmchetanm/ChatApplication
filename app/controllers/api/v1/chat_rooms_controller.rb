# frozen_string_literal: true

module Api
  module V1
    # Chat Rooms Controller
    class ChatRoomsController < Api::V1::ApiController
      before_action :find_chat_room, only: %i[update show destroy]

      # POST /chat_rooms
      def create
        @chat_room = ChatRoom.new(chat_room_params)
        
        if @chat_room.save
          render_success_response({
                                    chat_room: single_serializer.new(
                                      @chat_room, serializer: ChatRoomSerializer, current_user: current_user
                                    )
                                  },
                                  I18n.t('chat_room.create'), 200)
        else
          render_unprocessable_entity_response(@chat_room)
        end
      end

      # PATCH /chat_rooms
      def update
        if @chat_room.update(chat_room_params)
          render_success_response({
                                    chat_room: single_serializer.new(@chat_room, serializer: ChatRoomSerializer,
                                                                                 current_user: current_user)
                                  }, I18n.t('chat_room.update'), 200)
        else
          render_unprocessable_entity_response(@chat_room)
        end
      end

      # DELETE /chat_rooms
      def destroy
        if @chat_room.destroy
          render_success_response({
                                    chat_room: single_serializer.new(@chat_room, serializer: ChatRoomSerializer,
                                                                                 current_user: current_user)
                                  }, I18n.t('chat_room.delete'), 200)
        else
          render_unprocessable_entity_response(@chat_room)
        end
      end

      # SHOW /chat_rooms
      def show
        render_success_response({
                                  chat_room: single_serializer.new(@chat_room, serializer: ChatRoomSerializer,
                                                                               current_user: current_user)
                                }, '', 200)
      end

      private

      # Find Chat Room
      def find_chat_room
        @chat_room = ChatRoom.find(params[:id])

        return render_unprocessable_entity(I18n.t('chat_room.user_not_found')) unless @chat_room.users.include?(current_user)        
      end

      # Chat room params
      def chat_room_params
        params.require(:chat_room).merge({current_user_id: current_user.id}).permit(:name, :current_user_id, member_ids: [])
      end
    end
  end
end

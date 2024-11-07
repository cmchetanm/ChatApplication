# frozen_string_literal: true

module Api
  module V1
    # Messages Controller
    class MessagesController < Api::V1::ApiController
      before_action :find_chat_room

      # POST /chat_rooms/:chat_room_id/messages
      def create
        message = @chat_room.messages.new(message_params.merge(user: current_user))

        if message.save
          render_success_response({
                                    message: single_serializer.new(message, serializer: MessageSerializer)
                                  }, '', 200)
        else
          render_unprocessable_entity_response(message)
        end
      end

      private

      # Find chat room
      def find_chat_room
        @chat_room = ChatRoom.find(params[:chat_room_id])
      end

      # Message params
      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end

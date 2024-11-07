# frozen_string_literal: true

# ChatRoomMembership Model
class ChatRoomMembership < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user

  validate :user_count

  def user_count
    return if chat_room.nil? || chat_room.public_room? || chat_room.users.count < 2

    errors.add(:errors, I18n.t('chat_room.private_room_error'))
  end
end

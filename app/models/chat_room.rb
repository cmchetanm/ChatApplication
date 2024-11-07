# frozen_string_literal: true

# ChatRoom model
class ChatRoom < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :chat_room_memberships, dependent: :destroy
  has_many :users, through: :chat_room_memberships

  enum :chat_room_type, { public_room: 0, private_room: 1 }
 
  validates :name, presence: true
  validate :name_for_private_room, on: :update
  
  before_create :set_chat_room_name 
 
  attr_accessor :current_user_id

  def member_ids=(member_ids = [])
    self.users = User.where(id: member_ids << current_user_id)
  end
   
  def set_chat_room_name
    return if users.length > 2
    self.chat_room_type = :private_room
    self.name = private_room_name
  end

  private

  def private_room_name
    "#{users.first.full_name}_#{users.last.full_name}"
  end

  def name_for_private_room
    return unless private_room?

    errors.add(:base, I18n.t('chat_room.name_update'))
  end
end

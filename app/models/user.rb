# frozen_string_literal: true

# User model
class User < ApplicationRecord
  has_secure_password

  has_many :messages, dependent: :destroy
  has_many :chat_room_memberships, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_memberships

  validates :email, presence: true, uniqueness: true, allow_blank: false
  validates :full_name, presence: true, allow_blank: false
  validates :password_digest, presence: true, allow_blank: false
  validates :email,
            format: {
              with: /\A([^@\s]+)@((?:[-a-z0-9.]+\.)+[a-z]{2,})\z/
            }
end

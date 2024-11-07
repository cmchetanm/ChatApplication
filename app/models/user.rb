# frozen_string_literal: true

# User model
class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :password_digest, presence: true
end

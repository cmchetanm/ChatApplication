# frozen_string_literal: true

# BlackListedToken Model
class BlacklistedToken < ApplicationRecord
  validates :token, presence: true
  validates :exp, presence: true
end

# frozen_string_literal: true

# BlackListedToken Model
class BlacklistedToken < ApplicationRecord
  validates_presence_of :token, :exp
end

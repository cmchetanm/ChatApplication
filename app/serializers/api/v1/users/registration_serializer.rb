module Api
  module V1
    module Users
      class RegistrationSerializer < ActiveModel::Serializer
        attributes :id, :email, :full_name
      end
    end
  end
end

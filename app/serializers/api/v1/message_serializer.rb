module Api
  module V1
    class MessageSerializer < ActiveModel::Serializer
      attributes :id, :content, :created_at, :user

      attribute :user do |msg|
        object.user.full_name
      end
    end
  end
end

# app/serializers/api/v1/users/blog_serializer.rb

module Api
  module V1
    class ChatRoomSerializer < ActiveModel::Serializer
      attributes :id, :name, :chat_room_type
    
      has_many :users, through: :chat_room_memberships, serializer: Api::V1::Users::RegistrationSerializer
      has_many :messages, serializer: Api::V1::MessageSerializer
      attribute :name do |nm|
        if object.private_room? 
          object.users.where.not(id: instance_options[:current_user].id).first.full_name
        else
          object.name
        end
      end
    end
  end
end

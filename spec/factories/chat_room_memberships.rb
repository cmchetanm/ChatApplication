FactoryBot.define do
  factory :chat_room_membership do
    association :user
    association :chat_room
  end
end

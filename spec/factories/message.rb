FactoryBot.define do
    factory :message do
      content { 'Hello test message' }
      association :user, :chat_room
    end
  end
  
  
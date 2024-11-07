Rails.application.routes.draw do

  require 'sidekiq/web'
  
  namespace :api do
    namespace :v1 do
      namespace :users do
        post 'registrations', to: 'registrations#create'
        post 'password_reset', to: 'registrations#password_reset'
        get 'check_status', to: 'registrations#check_status'
        post 'sessions', to: 'sessions#create'
        post 'logout', to: 'sessions#logout'
      end

      resources :chat_rooms do
        resources :messages, only: [:index, :create]
      end
    end
  end

  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'
end

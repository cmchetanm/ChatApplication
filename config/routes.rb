# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'

  namespace :api do
    namespace :v1 do
      namespace :users do
        resources :registrations, only: [:create] do
          collection do
            post :password_reset
            get :check_status
          end
        end
        resources :sessions, only: [:create] do
          post :logout, on: :collection
        end
      end

      resources :chat_rooms do
        resources :messages, only: %i[index create]
      end
    end
  end

  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => '/sidekiq'
end

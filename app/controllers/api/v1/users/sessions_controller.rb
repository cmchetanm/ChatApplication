# frozen_string_literal: true

module Api
  module V1
    module Users
      # Sessions Controller
      class SessionsController < Api::V1::ApiController
        skip_before_action :authenticate_request, only: [:create]

        def create
          auth = AuthenticateUser.call(auth_params[:email], auth_params[:password])
          if auth.success?
            User.find_by_email(auth_params['email']).update(status: 'online')
            render_success_response({ response: auth.result }, I18n.t('login.success'))
          else
            render_unprocessable_entity(auth.errors)
          end
        end

        # POST /logout
        def logout
          header = request.headers['Authorization']
          header = header.split(' ').last if header

          BlacklistedToken.create(token: header, exp: Time.now)
          current_user.update(status: 'offline')
          render_success_response('', I18n.t('user.logout'), 200)
        end

        private

        def auth_params
          params.permit(:email, :password)
        end
      end
    end
  end
end

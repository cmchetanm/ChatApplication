# frozen_string_literal: true

module Api
  module V1
    module Users
      # Registrations Controller
      class RegistrationsController < Api::V1::ApiController
        skip_before_action :authenticate_request, only: %i[create check_status]
        before_action :find_user, only: :check_status

        def create
          unless registration_params[:email].present?
            return render_unprocessable_entity(I18n.t('errors.field_empty', resource: 'User',
                                                                            field: 'email'))
          end

          user = User.new(registration_params)
          if user.save
            render_success_response({ registration: single_serializer.new(user, serializer: RegistrationSerializer) })
          else
            render_unprocessable_entity_response(user)
          end
        end

        # POST /password_reset
        def password_reset
          if current_user.update!(password: params[:password])
            render_success_response('', I18n.t('login.password_reset'), 200)
          else
            render_unprocessable_entity_response(current_user)
          end
        end

        # GET /check_status
        def check_status
          render_success_response('', I18n.t('user.status', status: @user.status), 200)
        end

        private

        def registration_params
          params.permit(:full_name, :email, :password)
        end

        def find_user
          @user = User.find_by(id: params[:id])
          return render_unprocessable_entity(I18n.t('errors.user_not_found')) unless @user.present?
        end
      end
    end
  end
end

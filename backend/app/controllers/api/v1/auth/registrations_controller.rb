module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        def create
          build_resource(sign_up_params)
          resource.save
          if resource.persisted?
            sign_in(resource_name, resource, store: false)
            respond_with resource
          else
            clean_up_passwords resource
            set_minimum_password_length
            respond_with resource
          end
        end

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              user: UserSerializer.new(resource).as_json,
              token: request.env["warden-jwt_auth.token"]
            }, status: :created
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation)
        end
      end
    end
  end
end

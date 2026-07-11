module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              message: "Usuário criado com sucesso",
              user: {
                id: resource.id,
                email: resource.email,
                role: resource.role
              }
            }, status: :created
          else
            render json: {
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end

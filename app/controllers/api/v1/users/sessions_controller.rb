module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        skip_before_action :authenticate_user!, only: [:create], raise: false
        respond_to :json

          private

          def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              message: "Login realizado com sucesso",
              user: { id: resource.id, email: resource.email, role: resource.role }
            }, status: :ok
          else
            render json: { error: "Email ou senha inválidos" }, status: :unauthorized
          end
        end

        def respond_to_on_destroy
          render json: { message: "Logout realizado com sucesso" }, status: :ok
        end
      end
    end
  end
end
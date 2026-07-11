module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization
      before_action :authenticate_user!

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "Não autorizado" }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Registro não encontrado" }, status: :not_found
      end
    end
  end
end

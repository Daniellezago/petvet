class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!

  # Captura erro de autorização e redireciona
  rescue_from Pundit::NotAuthorizedError, with: :usuario_nao_autorizado

  private

  def usuario_nao_autorizado
    flash[:alert] = "Você não tem permissão para realizar esta ação."
    redirect_back(fallback_location: root_path)
  end
end
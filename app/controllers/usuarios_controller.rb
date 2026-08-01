class UsuariosController < ApplicationController
  before_action :set_usuario, only: [ :show, :edit, :update ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  def index
    @usuarios = policy_scope(User).page(params[:page]).per(10)
  end

  def show
    authorize @usuario
  end

  def new
    @usuario = User.new
    authorize @usuario
  end

  def create
    @usuario = User.new(usuario_params)
    authorize @usuario
    if @usuario.save
      redirect_to usuarios_path, notice: "Usuário criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @usuario
  end

  def update
    authorize @usuario
    if @usuario.update(usuario_params.reject { |_, v| v.blank? })
      redirect_to usuarios_path, notice: "Usuário atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_usuario
    @usuario = User.find(params[:id])
  end

  def usuario_params
    params.require(:user).permit(:email, :role, :ativo, :crmv, :password, :password_confirmation)
  end
end

class ExamesController < ApplicationController
  before_action :set_exame, only: [ :show, :edit, :update ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  def index
    @exames = policy_scope(Exame).includes(:pet, :usuario).page(params[:page]).per(10)
  end

  def show
    authorize @exame
  end

  def new
    @exame = Exame.new
    authorize @exame
  end

  def create
    @exame = Exame.new(exame_params.merge(usuario: current_user))
    authorize @exame
    if @exame.save
      redirect_to @exame, notice: "Exame registrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @exame
  end

  def update
    authorize @exame
    if @exame.update(exame_params)
      redirect_to @exame, notice: "Exame atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_exame
    @exame = Exame.find(params[:id])
  end

  def exame_params
    params.require(:exame).permit(:tipo_exame, :data, :resultado, :observacoes, :pet_id, :arquivo)
  end
end

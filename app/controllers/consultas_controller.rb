class ConsultasController < ApplicationController
  before_action :set_consulta, only: [ :show, :edit, :update ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  def index
    @consultas = policy_scope(Consulta).includes(:pet, :usuario).page(params[:page]).per(10)
  end

  def show
    authorize @consulta
  end

  def new
    @consulta = Consulta.new
    authorize @consulta
  end

  def create
    @consulta = Consulta.new(consulta_params.merge(usuario: current_user))
    authorize @consulta
    if @consulta.save
      redirect_to @consulta, notice: "Consulta registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @consulta
  end

  def update
    authorize @consulta
    if @consulta.update(consulta_params)
      redirect_to @consulta, notice: "Consulta atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_consulta
    @consulta = Consulta.find(params[:id])
  end

  def consulta_params
    params.require(:consulta).permit(:data, :descricao, :diagnostico, :tratamento, :observacoes, :pet_id)
  end
end

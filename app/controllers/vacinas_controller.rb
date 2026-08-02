class VacinasController < ApplicationController
  before_action :set_vacina, only: [ :show, :edit, :update ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  def index
    @vacinas = policy_scope(Vacina).includes(:pet, :usuario).page(params[:page]).per(10)
  end

  def show
    authorize @vacina
  end

  def new
    @vacina = Vacina.new
    authorize @vacina
  end

  def create
    @vacina = Vacina.new(vacina_params.merge(usuario: current_user))
    authorize @vacina
    if @vacina.save
      redirect_to @vacina, notice: "Vacina registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @vacina
  end

  def update
    authorize @vacina
    if @vacina.update(vacina_params)
      redirect_to @vacina, notice: "Vacina atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_vacina
    @vacina = Vacina.find(params[:id])
  end

  def vacina_params
    params.require(:vacina).permit(:nome, :data_aplicacao, :proxima_dose, :lote, :fabricante, :observacoes, :pet_id)
  end

  def vacina_params
    params.require(:vacina).permit(:nome, :categoria, :data_aplicacao, :proxima_dose, :lote, :fabricante, :observacoes, :pet_id)
  end
end

class PesosController < ApplicationController
  before_action :set_peso, only: [ :show, :edit, :update ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  def index
    @pesos = policy_scope(Peso).includes(:pet, :usuario).page(params[:page]).per(10)
  end

  def show
    authorize @peso
  end

  def new
    @peso = Peso.new
    authorize @peso
  end

  def create
    @peso = Peso.new(peso_params.merge(usuario: current_user))
    authorize @peso
    if @peso.save
      redirect_to @peso, notice: "Pesagem registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @peso
  end

  def update
    authorize @peso
    if @peso.update(peso_params)
      redirect_to @peso, notice: "Pesagem atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_peso
    @peso = Peso.find(params[:id])
  end

  def peso_params
    params.require(:peso).permit(:data, :peso, :observacoes, :pet_id)
  end
end

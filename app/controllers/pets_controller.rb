class PetsController < ApplicationController
  before_action :set_pet, only: [ :show, :edit, :update ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  COLUNAS_ORDENAVEIS = {
    "nome" => "pets.nome",
    "especie" => "pets.especie",
    "porte" => "pets.porte",
    "cor" => "pets.cor",
    "peso_atual" => "pets.peso_atual",
    "data_nascimento" => "pets.data_nascimento"
  }.freeze
  PER_PAGE_PERMITIDOS = [ 10, 20, 50 ].freeze

  def index
    @pets = policy_scope(Pet).includes(:tutor)

    if params[:busca].present?
      termo = "%#{params[:busca]}%"
      @pets = @pets.references(:tutor)
                  .where("pets.nome LIKE :t OR pets.especie LIKE :t OR tutors.nome LIKE :t", t: termo)
    end

    coluna = COLUNAS_ORDENAVEIS.fetch(params[:sort], "pets.nome")
    direcao = params[:direction] == "desc" ? "desc" : "asc"

    por_pagina = PER_PAGE_PERMITIDOS.include?(params[:per_page].to_i) ? params[:per_page].to_i : 10

    @pets = @pets.order(coluna => direcao).page(params[:page]).per(por_pagina)
  end

  def show
    authorize @pet
  end

  def new
    @pet = Pet.new
    authorize @pet
  end

  def create
    @pet = Pet.new(pet_params)
    authorize @pet
    if @pet.save
      redirect_to @pet, notice: "Pet cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @pet
  end

  def update
    authorize @pet
    if @pet.update(pet_params)
      redirect_to @pet, notice: "Pet atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:id])
  end

  def pet_params
    params.require(:pet).permit(:nome, :especie, :raca, :sexo, :porte, :cor, :castrado, :data_nascimento, :peso_atual, :tutor_id, :foto)
  end
end

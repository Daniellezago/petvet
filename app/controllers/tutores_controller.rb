class TutoresController < ApplicationController
  before_action :set_tutor, only: [ :show, :edit, :update, :destroy ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  COLUNAS_ORDENAVEIS = %w[nome cpf email].freeze
  PER_PAGE_PERMITIDOS = [ 10, 20, 50 ].freeze

  def index
    @tutores = policy_scope(Tutor)
    @tutores = @tutores.ativos unless params[:mostrar_inativos] == "1"

    if params[:busca].present?
      termo = "%#{params[:busca]}%"
      @tutores = @tutores.where("nome LIKE :t OR email LIKE :t OR cpf LIKE :t", t: termo)
    end

    coluna = COLUNAS_ORDENAVEIS.include?(params[:sort]) ? params[:sort] : "nome"
    direcao = params[:direction] == "desc" ? "desc" : "asc"

    por_pagina = PER_PAGE_PERMITIDOS.include?(params[:per_page].to_i) ? params[:per_page].to_i : 10

    @tutores = @tutores.order(coluna => direcao).page(params[:page]).per(por_pagina)
  end

  def show
    authorize @tutor
  end

  def new
    @tutor = Tutor.new
    authorize @tutor
  end

  def create
    @tutor = Tutor.new(tutor_params)
    authorize @tutor

    if @tutor.save
      redirect_to @tutor, notice: "Tutor cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @tutor
  end

  def update
    authorize @tutor

    if @tutor.update(tutor_params)
      redirect_to @tutor, notice: "Tutor atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tutor
    @tutor.update!(ativo: false)
    head :no_content
  end

  private

  def set_tutor
    @tutor = Tutor.find(params[:id])
  end

  def tutor_params
    params.require(:tutor).permit(
      :nome, :email, :telefone, :cpf, :endereco
    )
    # SEGURANÇA: :ativo e :deleted_at NÃO estão aqui
    # O usuário nunca pode manipular esses campos via formulário
  end
end

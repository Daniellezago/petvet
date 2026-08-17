class VeterinariosController < ApplicationController
  before_action :set_veterinario, only: [ :show, :edit, :update, :destroy, :reativar ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  COLUNAS_ORDENAVEIS = %w[nome crmv].freeze
  PER_PAGE_PERMITIDOS = [ 10, 20, 50 ].freeze

  def index
    @veterinarios = policy_scope(Veterinario)

    if params[:busca].present?
      termo = "%#{params[:busca]}%"
      @veterinarios = @veterinarios.where("nome LIKE :t OR crmv LIKE :t OR especialidade LIKE :t", t: termo)
    elsif params[:mostrar_inativos] == "1"
      @veterinarios = @veterinarios.where(ativo: false)
    else
      @veterinarios = @veterinarios.ativos
    end

    coluna = COLUNAS_ORDENAVEIS.include?(params[:sort]) ? params[:sort] : "nome"
    direcao = params[:direction] == "desc" ? "desc" : "asc"
    por_pagina = PER_PAGE_PERMITIDOS.include?(params[:per_page].to_i) ? params[:per_page].to_i : 10

    @veterinarios = @veterinarios.includes(:user).order(coluna => direcao).page(params[:page]).per(por_pagina)
  end

  def show
    authorize @veterinario
  end

  def new
    @veterinario = Veterinario.new
    authorize @veterinario
  end

  def create
    @veterinario = Veterinario.new(veterinario_params)
    authorize @veterinario

    if @veterinario.save
      redirect_to @veterinario, notice: "Veterinário cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @veterinario
  end

  def update
    authorize @veterinario

    if @veterinario.update(veterinario_params)
      redirect_to @veterinario, notice: "Veterinário atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @veterinario
    @veterinario.update!(ativo: false)
    redirect_to veterinarios_path, notice: "Veterinário desativado com sucesso."
  end

  def reativar
    authorize @veterinario
    @veterinario.update!(ativo: true)
    redirect_to veterinarios_path, notice: "Veterinário reativado com sucesso."
  end

  private

  def set_veterinario
    @veterinario = Veterinario.find(params[:id])
  end

  def veterinario_params
    params.require(:veterinario).permit(:nome, :crmv, :especialidade, :cor_agenda, :user_id)
  end

  # Usuários com role=veterinario que ainda não têm perfil de Veterinario criado.
  # Na edição, inclui o próprio usuário já vinculado a este registro (senão ele
  # desapareceria da lista e o formulário quebraria a seleção atual).
  helper_method def usuarios_disponiveis
    ids_ocupados = Veterinario.where.not(id: @veterinario&.id).pluck(:user_id)
    User.veterinario.where.not(id: ids_ocupados)
  end
end

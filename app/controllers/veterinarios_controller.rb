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
    @veterinario.build_user(role: :veterinario)
    authorize @veterinario
  end

  def create
    @veterinario = Veterinario.new(veterinario_params)
    # SEGURANÇA: o papel do usuário nunca vem do formulário, é sempre forçado aqui.
    # Impede que alguém manipule o request e crie um admin disfarçado de veterinário.
    @veterinario.user&.role = :veterinario
    authorize @veterinario

    if @veterinario.save
      redirect_to @veterinario, notice: "Veterinário cadastrado com sucesso! Login criado para #{@veterinario.user.email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @veterinario
  end

  def update
    authorize @veterinario

    # Na edição não mexemos no login (email/senha) — só nos dados profissionais.
    if @veterinario.update(veterinario_params_edicao)
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
    params.require(:veterinario).permit(
      :nome, :crmv, :especialidade, :cor_agenda,
      user_attributes: [ :email, :password, :password_confirmation ]
    )
  end

  def veterinario_params_edicao
    params.require(:veterinario).permit(:nome, :crmv, :especialidade, :cor_agenda)
  end
end

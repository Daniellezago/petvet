class TutoresController < ApplicationController
  before_action :set_tutor, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized

  def index
    @tutores = policy_scope(Tutor).page(params[:page]).per(10)
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
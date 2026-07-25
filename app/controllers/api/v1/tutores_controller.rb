module Api
  module V1
    class TutoresController < Api::V1::BaseController
      before_action :set_tutor, only: [ :show, :update, :destroy ]

      def index
        tutores = policy_scope(Tutor).page(params[:page]).per(20)
        render json: {
          tutores: tutores,
          meta: {
            pagina_atual: tutores.current_page,
            total_paginas: tutores.total_pages,
            total_registros: tutores.total_count
    }
  }
end

      def show
        authorize @tutor
        render json: @tutor
      end

      def create
        tutor = Tutor.new(tutor_params)
        authorize tutor

        if tutor.save
          render json: tutor, status: :created
        else
          render json: { errors: tutor.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @tutor

        if @tutor.update(tutor_params)
          render json: @tutor
        else
          render json: { errors: @tutor.errors.full_messages }, status: :unprocessable_content
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
        params.require(:tutor).permit(:nome, :email, :telefone, :cpf, :endereco)
      end
    end
  end
end

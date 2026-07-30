module Api
  module V1
    class PesosController < Api::V1::BaseController
      before_action :set_peso, only: [ :show, :update ]

      def index
        pesos = policy_scope(Peso).includes(:pet, :usuario).page(params[:page]).per(20)
        render json: {
          pesos: pesos,
          meta: {
            pagina_atual: pesos.current_page,
            total_paginas: pesos.total_pages,
            total_registros: pesos.total_count
          }
        }
      end

      def show
        authorize @peso
        render json: @peso
      end

      def create
        peso = Peso.new(peso_params.merge(usuario: current_user))
        authorize peso
        if peso.save
          render json: peso, status: :created
        else
          render json: { errors: peso.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @peso
        if @peso.update(peso_params)
          render json: @peso
        else
          render json: { errors: @peso.errors.full_messages }, status: :unprocessable_content
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
  end
end

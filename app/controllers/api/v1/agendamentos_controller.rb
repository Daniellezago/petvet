module Api
  module V1
    class AgendamentosController < Api::V1::BaseController
      before_action :set_agendamento, only: [ :show, :update, :destroy ]

      def index
        agendamentos = policy_scope(Agendamento).includes(:tutor, :pet, :usuario).page(params[:page]).per(20)
        render json: {
          agendamentos: agendamentos,
          meta: {
            pagina_atual: agendamentos.current_page,
            total_paginas: agendamentos.total_pages,
            total_registros: agendamentos.total_count
    }
  }
end

      def show
        authorize @agendamento
        render json: @agendamento
      end

      def create
        # usuario_id NUNCA vem do formulário — sempre é o usuário autenticado
        agendamento = Agendamento.new(agendamento_params.merge(usuario: current_user))
        authorize agendamento

        if agendamento.save
          render json: agendamento, status: :created
        else
          render json: { errors: agendamento.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @agendamento

        if @agendamento.update(agendamento_params)
          render json: @agendamento
        else
          render json: { errors: @agendamento.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        authorize @agendamento
        @agendamento.destroy
        head :no_content
      end

      private

      def set_agendamento
        @agendamento = Agendamento.find(params[:id])
      end

      # usuario_id NÃO está na lista — é sempre definido pelo controller
      def agendamento_params
        params.require(:agendamento).permit(:data_hora, :status, :observacoes, :tutor_id, :pet_id)
      end
    end
  end
end

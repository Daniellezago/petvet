module Api
  module V1
    class ConsultasController < Api::V1::BaseController
      before_action :set_consulta, only: [ :show, :update ]

      def index
        consultas = policy_scope(Consulta)
        render json: consultas
      end

      def show
        authorize @consulta
        render json: @consulta
      end

      def create
        # usuario_id NUNCA vem do formulário — sempre é o usuário autenticado
        consulta = Consulta.new(consulta_params.merge(usuario: current_user))
        authorize consulta

        if consulta.save
          render json: consulta, status: :created
        else
          render json: { errors: consulta.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @consulta

        if @consulta.update(consulta_params)
          render json: @consulta
        else
          render json: { errors: @consulta.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_consulta
        @consulta = Consulta.find(params[:id])
      end

      # usuario_id NÃO está na lista — proposital, é sempre definido pelo controller
      def consulta_params
        params.require(:consulta).permit(:data, :descricao, :diagnostico, :tratamento, :observacoes, :pet_id)
      end
    end
  end
end

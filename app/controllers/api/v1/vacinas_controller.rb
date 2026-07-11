module Api
  module V1
    class VacinasController < Api::V1::BaseController
      before_action :set_vacina, only: [ :show, :update ]

      def index
        vacinas = policy_scope(Vacina)
        render json: vacinas
      end

      def show
        authorize @vacina
        render json: @vacina
      end

      def create
        # usuario_id NUNCA vem do formulário — sempre é o usuário autenticado
        vacina = Vacina.new(vacina_params.merge(usuario: current_user))
        authorize vacina

        if vacina.save
          render json: vacina, status: :created
        else
          render json: { errors: vacina.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @vacina

        if @vacina.update(vacina_params)
          render json: @vacina
        else
          render json: { errors: @vacina.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_vacina
        @vacina = Vacina.find(params[:id])
      end

      # usuario_id NÃO está na lista — é sempre definido pelo controller
      def vacina_params
        params.require(:vacina).permit(:nome, :data_aplicacao, :proxima_dose, :lote, :fabricante, :observacoes, :pet_id)
      end
    end
  end
end

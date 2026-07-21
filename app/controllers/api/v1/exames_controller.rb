module Api
  module V1
    class ExamesController < Api::V1::BaseController
      before_action :set_exame, only: [ :show, :update ]

      def index
      exames = policy_scope(Exame).includes(:pet, :usuario)
      render json: exames
end

      def show
        authorize @exame
        render json: @exame
      end

      def create
        # usuario_id NUNCA vem do formulário — sempre é o usuário autenticado
        exame = Exame.new(exame_params.merge(usuario: current_user))
        authorize exame

        if exame.save
          render json: exame, status: :created
        else
          render json: { errors: exame.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @exame

        if @exame.update(exame_params)
          render json: @exame
        else
          render json: { errors: @exame.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_exame
        @exame = Exame.find(params[:id])
      end

      # usuario_id NÃO está na lista — é sempre definido pelo controller
      def exame_params
        params.require(:exame).permit(:tipo_exame, :data, :resultado, :observacoes, :pet_id, :arquivo)
      end
    end
  end
end
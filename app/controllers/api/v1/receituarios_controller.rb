module Api
  module V1
    class ReceituariosController < Api::V1::BaseController
      before_action :set_receituario, only: [ :show, :update ]

      def index
        receituarios = policy_scope(Receituario)
        render json: receituarios
      end

      def show
        authorize @receituario
        render json: @receituario
      end

      def create
        receituario = Receituario.new(receituario_params)
        # usuario e crmv_responsavel NUNCA vêm do formulário —
        # sempre são derivados do usuário autenticado
        receituario.usuario = current_user
        receituario.crmv_responsavel = current_user.crmv

        authorize receituario

        if receituario.save
          render json: receituario, status: :created
        else
          render json: { errors: receituario.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @receituario

        if @receituario.update(receituario_params)
          render json: @receituario
        else
          render json: { errors: @receituario.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_receituario
        @receituario = Receituario.find(params[:id])
      end

      # usuario_id e crmv_responsavel NÃO estão na lista — são sempre
      # definidos pelo controller a partir do usuário autenticado
      def receituario_params
        params.require(:receituario).permit(:tipo_receituario, :medicamento, :posologia, :duracao_tratamento, :observacoes, :data_emissao, :pet_id)
      end
    end
  end
end

module Api
  module V1
    class ContratosController < Api::V1::BaseController
      before_action :set_contrato, only: [ :show, :update, :destroy ]

      def index
        contratos = policy_scope(Contrato).includes(:tutor, :pet)
        render json: contratos
      end

      def show
        authorize @contrato
        render json: @contrato
      end

      def create
        contrato = Contrato.new(contrato_params)
        authorize contrato

        if contrato.save
          render json: contrato, status: :created
        else
          render json: { errors: contrato.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @contrato

        if @contrato.update(contrato_params)
          render json: @contrato
        else
          render json: { errors: @contrato.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        authorize @contrato
        @contrato.destroy
        head :no_content
      end

      private

      def set_contrato
        @contrato = Contrato.find(params[:id])
      end

      def contrato_params
        params.require(:contrato).permit(
          :tipo_contrato, :nome_convenio, :numero_carteirinha,
          :percentual_cobertura, :data_inicio, :data_fim,
          :tutor_id, :pet_id
        )
      end
    end
  end
end
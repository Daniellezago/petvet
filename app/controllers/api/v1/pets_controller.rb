module Api
  module V1
    class PetsController < Api::V1::BaseController
      before_action :set_pet, only: [ :show, :update ]

      def index
        pets = policy_scope(Pet)
        render json: pets
      end

      def show
        authorize @pet
        render json: @pet
      end

      def create
        pet = Pet.new(pet_params)
        authorize pet

        if pet.save
          render json: pet, status: :created
        else
          render json: { errors: pet.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        authorize @pet

        if @pet.update(update_params)
          render json: @pet
        else
          render json: { errors: @pet.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_pet
        @pet = Pet.find(params[:id])
      end

      # tutor_id permitido apenas na criação
      def pet_params
        params.require(:pet).permit(:nome, :especie, :raca, :sexo, :data_nascimento, :peso_atual, :tutor_id)
      end

      # tutor_id NÃO permitido na atualização — evita reatribuição do pet para outro tutor via PATCH
      def update_params
        params.require(:pet).permit(:nome, :especie, :raca, :sexo, :data_nascimento, :peso_atual)
      end
    end
  end
end

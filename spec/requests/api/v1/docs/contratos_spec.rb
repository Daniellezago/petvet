require "swagger_helper"

RSpec.describe "Api::V1::Contratos", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }
  let(:contrato_existente) { create(:contrato, tutor: tutor, pet: pet) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
         params: { user: { email: admin.email, password: senha } },
         as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/contratos" do
    get "Lista os contratos" do
      tags "Contratos"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            contratos: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  tipo_contrato: { type: :string, enum: [ "particular", "convenio" ] },
                  nome_convenio: { type: :string, nullable: true },
                  numero_carteirinha: { type: :string, nullable: true },
                  percentual_cobertura: { type: :number, nullable: true },
                  data_inicio: { type: :string, format: :date },
                  data_fim: { type: :string, format: :date, nullable: true },
                  tutor_id: { type: :integer },
                  pet_id: { type: :integer }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                pagina_atual: { type: :integer },
                total_paginas: { type: :integer },
                total_registros: { type: :integer }
              }
            }
          }
        run_test!
      end

      response "401", "não autenticado" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post "Cria um novo contrato" do
      tags "Contratos"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      description "Se tipo_contrato for 'convenio', nome_convenio, numero_carteirinha e " \
                   "percentual_cobertura são obrigatórios. O pet deve pertencer ao tutor informado."

      parameter name: :contrato, in: :body, schema: {
        type: :object,
        properties: {
          contrato: {
            type: :object,
            properties: {
              tipo_contrato: { type: :string, enum: [ "particular", "convenio" ] },
              nome_convenio: { type: :string },
              numero_carteirinha: { type: :string },
              percentual_cobertura: { type: :number },
              data_inicio: { type: :string, format: :date },
              data_fim: { type: :string, format: :date },
              tutor_id: { type: :integer },
              pet_id: { type: :integer }
            },
            required: [ "data_inicio", "tutor_id", "pet_id" ]
          }
        }
      }

      response "201", "contrato criado com sucesso" do
        let(:contrato) do
          {
            contrato: {
              tipo_contrato: "particular",
              data_inicio: Date.current,
              tutor_id: tutor.id,
              pet_id: pet.id
            }
          }
        end
        run_test!
      end

      response "422", "dados inválidos" do
        let(:contrato) { { contrato: { data_inicio: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/contratos/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe um contrato específico" do
      tags "Contratos"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "contrato encontrado" do
        let(:id) { contrato_existente.id }
        run_test!
      end

      response "404", "contrato não encontrado" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza um contrato" do
      tags "Contratos"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :contrato, in: :body, schema: {
        type: :object,
        properties: {
          contrato: {
            type: :object,
            properties: {
              percentual_cobertura: { type: :number }
            }
          }
        }
      }

      response "200", "contrato atualizado com sucesso" do
        let(:id) { contrato_existente.id }
        let(:contrato) { { contrato: { percentual_cobertura: 90.0 } } }
        run_test!
      end
    end

    delete "Remove um contrato" do
      tags "Contratos"
      security [ bearer_auth: [] ]
      description "Restrito a administradores (403 para outros papéis)."

      response "204", "contrato removido com sucesso" do
        let(:id) { contrato_existente.id }
        run_test!
      end
    end
  end
end

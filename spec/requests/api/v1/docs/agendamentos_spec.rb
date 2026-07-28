require "swagger_helper"

RSpec.describe "Api::V1::Agendamentos", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }
  let(:agendamento_existente) { create(:agendamento, tutor: tutor, pet: pet, usuario: admin) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
         params: { user: { email: admin.email, password: senha } },
         as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/agendamentos" do
    get "Lista os agendamentos" do
      tags "Agendamentos"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            agendamentos: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  data_hora: { type: :string, format: "date-time" },
                  status: { type: :string, enum: [ "agendado", "confirmado", "realizado", "cancelado" ] },
                  observacoes: { type: :string, nullable: true },
                  tutor_id: { type: :integer },
                  pet_id: { type: :integer },
                  usuario_id: { type: :integer }
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

    post "Cria um novo agendamento" do
      tags "Agendamentos"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      description "O pet informado deve pertencer ao tutor informado, senão retorna 422."

      parameter name: :agendamento, in: :body, schema: {
        type: :object,
        properties: {
          agendamento: {
            type: :object,
            properties: {
              data_hora: { type: :string, format: "date-time" },
              observacoes: { type: :string },
              tutor_id: { type: :integer },
              pet_id: { type: :integer }
            },
            required: [ "data_hora", "tutor_id", "pet_id" ]
          }
        }
      }

      response "201", "agendamento criado com sucesso" do
        let(:agendamento) do
          {
            agendamento: {
              data_hora: 1.day.from_now,
              observacoes: "Consulta de rotina",
              tutor_id: tutor.id,
              pet_id: pet.id
            }
          }
        end
        run_test!
      end

      response "422", "dados inválidos ou pet não pertence ao tutor" do
        let(:agendamento) { { agendamento: { data_hora: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/agendamentos/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe um agendamento específico" do
      tags "Agendamentos"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "agendamento encontrado" do
        let(:id) { agendamento_existente.id }
        run_test!
      end

      response "404", "agendamento não encontrado" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza um agendamento" do
      tags "Agendamentos"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :agendamento, in: :body, schema: {
        type: :object,
        properties: {
          agendamento: {
            type: :object,
            properties: {
              status: { type: :string, enum: [ "agendado", "confirmado", "realizado", "cancelado" ] }
            }
          }
        }
      }

      response "200", "agendamento atualizado com sucesso" do
        let(:id) { agendamento_existente.id }
        let(:agendamento) { { agendamento: { status: "confirmado" } } }
        run_test!
      end
    end

    delete "Remove um agendamento" do
      tags "Agendamentos"
      security [ bearer_auth: [] ]
      description "Restrito a administradores (403 para outros papéis)."

      response "204", "agendamento removido com sucesso" do
        let(:id) { agendamento_existente.id }
        run_test!
      end
    end
  end
end

require "swagger_helper"

RSpec.describe "Api::V1::Consultas", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }
  let(:consulta_existente) { create(:consulta, pet: pet, usuario: admin) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
        params: { user: { email: admin.email, password: senha } },
        as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/consultas" do
    get "Lista as consultas" do
      tags "Consultas"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            consultas: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  data: { type: :string, format: "date-time" },
                  descricao: { type: :string },
                  diagnostico: { type: :string, nullable: true },
                  tratamento: { type: :string, nullable: true },
                  observacoes: { type: :string, nullable: true },
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

    post "Cria uma nova consulta" do
      tags "Consultas"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      description "usuario_id é sempre o usuário autenticado — nunca aceito via parâmetro, mesmo se enviado."

      parameter name: :consulta, in: :body, schema: {
        type: :object,
        properties: {
          consulta: {
            type: :object,
            properties: {
              data: { type: :string, format: "date-time" },
              descricao: { type: :string },
              diagnostico: { type: :string },
              tratamento: { type: :string },
              observacoes: { type: :string },
              pet_id: { type: :integer }
            },
            required: [ "data", "descricao", "pet_id" ]
          }
        }
      }

      response "201", "consulta criada com sucesso" do
        let(:consulta) do
          {
            consulta: {
              data: 1.day.ago,
              descricao: "Consulta de rotina",
              diagnostico: "Animal saudável",
              pet_id: pet.id
            }
          }
        end
        run_test!
      end

      response "422", "dados inválidos" do
        let(:consulta) { { consulta: { descricao: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/consultas/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe uma consulta específica" do
      tags "Consultas"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "consulta encontrada" do
        let(:id) { consulta_existente.id }
        run_test!
      end

      response "404", "consulta não encontrada" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza uma consulta" do
      tags "Consultas"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :consulta, in: :body, schema: {
        type: :object,
        properties: {
          consulta: {
            type: :object,
            properties: {
              descricao: { type: :string },
              tratamento: { type: :string }
            }
          }
        }
      }

      response "200", "consulta atualizada com sucesso" do
        let(:id) { consulta_existente.id }
        let(:consulta) { { consulta: { descricao: "Descrição atualizada" } } }
        run_test!
      end
    end
  end
end

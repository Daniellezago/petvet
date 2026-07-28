require "swagger_helper"

RSpec.describe "Api::V1::Vacinas", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }
  let(:vacina_existente) { create(:vacina, pet: pet, usuario: admin) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
        params: { user: { email: admin.email, password: senha } },
        as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/vacinas" do
    get "Lista as vacinas" do
      tags "Vacinas"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            vacinas: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  nome: { type: :string },
                  data_aplicacao: { type: :string, format: :date },
                  proxima_dose: { type: :string, format: :date, nullable: true },
                  lote: { type: :string, nullable: true },
                  fabricante: { type: :string, nullable: true },
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

    post "Cria uma nova vacina" do
      tags "Vacinas"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      description "usuario_id é sempre o usuário autenticado — nunca aceito via parâmetro."

      parameter name: :vacina, in: :body, schema: {
        type: :object,
        properties: {
          vacina: {
            type: :object,
            properties: {
              nome: { type: :string },
              data_aplicacao: { type: :string, format: :date },
              proxima_dose: { type: :string, format: :date },
              lote: { type: :string },
              fabricante: { type: :string },
              observacoes: { type: :string },
              pet_id: { type: :integer }
            },
            required: [ "nome", "data_aplicacao", "pet_id" ]
          }
        }
      }

      response "201", "vacina criada com sucesso" do
        let(:vacina) do
          {
            vacina: {
              nome: "V10",
              data_aplicacao: 1.week.ago.to_date,
              proxima_dose: 1.year.from_now.to_date,
              lote: "L1234",
              fabricante: "Zoetis",
              pet_id: pet.id
            }
          }
        end
        run_test!
      end

      response "422", "dados inválidos" do
        let(:vacina) { { vacina: { nome: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/vacinas/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe uma vacina específica" do
      tags "Vacinas"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "vacina encontrada" do
        let(:id) { vacina_existente.id }
        run_test!
      end

      response "404", "vacina não encontrada" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza uma vacina" do
      tags "Vacinas"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :vacina, in: :body, schema: {
        type: :object,
        properties: {
          vacina: {
            type: :object,
            properties: {
              lote: { type: :string }
            }
          }
        }
      }

      response "200", "vacina atualizada com sucesso" do
        let(:id) { vacina_existente.id }
        let(:vacina) { { vacina: { lote: "Lote atualizado" } } }
        run_test!
      end
    end
  end
end

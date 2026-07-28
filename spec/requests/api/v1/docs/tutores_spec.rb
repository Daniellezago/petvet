require "swagger_helper"

RSpec.describe "Api::V1::Tutores", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
        params: { user: { email: admin.email, password: senha } },
        as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/tutores" do
    get "Lista os tutores" do
      tags "Tutores"
      security [ bearer_auth: [] ]
      produces "application/json"

      parameter name: :page, in: :query, type: :integer, required: false,
                description: "Número da página (padrão: 1)"

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            tutores: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  nome: { type: :string },
                  email: { type: :string },
                  cpf: { type: :string },
                  telefone: { type: :string },
                  ativo: { type: :boolean }
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

    post "Cria um novo tutor" do
      tags "Tutores"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :tutor, in: :body, schema: {
        type: :object,
        properties: {
          tutor: {
            type: :object,
            properties: {
              nome: { type: :string },
              email: { type: :string },
              telefone: { type: :string },
              cpf: { type: :string },
              endereco: { type: :string }
            },
            required: [ "nome", "email", "telefone", "cpf" ]
          }
        }
      }

      response "201", "tutor criado com sucesso" do
        let(:tutor) do
          {
            tutor: {
              nome: "João Silva",
              email: "joao.silva@email.com",
              telefone: "11999999999",
              cpf: "123.456.789-00"
            }
          }
        end

        run_test!
      end

      response "422", "dados inválidos" do
        let(:tutor) { { tutor: { nome: "" } } }
        run_test!
      end
    end
  end
end

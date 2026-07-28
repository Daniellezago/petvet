require "swagger_helper"

RSpec.describe "Api::V1::Exames", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }
  let(:exame_existente) { create(:exame, pet: pet, usuario: admin) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
         params: { user: { email: admin.email, password: senha } },
         as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/exames" do
    get "Lista os exames" do
      tags "Exames"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            exames: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  tipo_exame: { type: :string },
                  data: { type: :string, format: :date },
                  resultado: { type: :string, nullable: true },
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

    post "Cria um novo exame" do
      tags "Exames"
      security [ bearer_auth: [] ]
      consumes "multipart/form-data"
      produces "application/json"
      description "Aceita upload opcional de arquivo (PDF, JPEG ou PNG) via campo 'arquivo'. " \
                   "usuario_id é sempre o usuário autenticado — nunca aceito via parâmetro."

      parameter name: "exame[tipo_exame]", in: :formData, type: :string, required: true
      parameter name: "exame[data]", in: :formData, type: :string, required: true
      parameter name: "exame[resultado]", in: :formData, type: :string, required: false
      parameter name: "exame[observacoes]", in: :formData, type: :string, required: false
      parameter name: "exame[pet_id]", in: :formData, type: :integer, required: true
      parameter name: "exame[arquivo]", in: :formData, type: :file, required: false,
                description: "Arquivo do laudo — apenas PDF, JPEG ou PNG são aceitos"

      response "201", "exame criado com sucesso" do
        let(:"exame[tipo_exame]") { "Hemograma completo" }
        let(:"exame[data]") { 1.week.ago.to_date.to_s }
        let(:"exame[pet_id]") { pet.id }
        run_test!
      end

      response "422", "dados inválidos" do
        let(:"exame[tipo_exame]") { "" }
        let(:"exame[data]") { 1.week.ago.to_date.to_s }
        let(:"exame[pet_id]") { pet.id }
        run_test!
      end
    end
  end

  path "/api/v1/exames/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe um exame específico" do
      tags "Exames"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "exame encontrado" do
        let(:id) { exame_existente.id }
        run_test!
      end

      response "404", "exame não encontrado" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza um exame" do
      tags "Exames"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :exame, in: :body, schema: {
        type: :object,
        properties: {
          exame: {
            type: :object,
            properties: {
              resultado: { type: :string }
            }
          }
        }
      }

      response "200", "exame atualizado com sucesso" do
        let(:id) { exame_existente.id }
        let(:exame) { { exame: { resultado: "Resultado atualizado" } } }
        run_test!
      end
    end
  end
end

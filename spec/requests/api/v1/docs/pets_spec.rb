require "swagger_helper"

RSpec.describe "Api::V1::Pets", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet_existente) { create(:pet, tutor: tutor) }

  let(:Authorization) do
    post "/api/v1/users/sign_in",
        params: { user: { email: admin.email, password: senha } },
        as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/pets" do
    get "Lista os pets" do
      tags "Pets"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            pets: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  nome: { type: :string },
                  especie: { type: :string },
                  raca: { type: :string, nullable: true },
                  sexo: { type: :string },
                  data_nascimento: { type: :string, format: :date, nullable: true },
                  peso_atual: { type: :number, nullable: true },
                  tutor_id: { type: :integer }
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

    post "Cria um novo pet" do
      tags "Pets"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :pet, in: :body, schema: {
        type: :object,
        properties: {
          pet: {
            type: :object,
            properties: {
              nome: { type: :string },
              especie: { type: :string },
              raca: { type: :string },
              sexo: { type: :string, enum: [ "macho", "femea" ] },
              data_nascimento: { type: :string, format: :date },
              peso_atual: { type: :number },
              tutor_id: { type: :integer }
            },
            required: [ "nome", "especie", "sexo", "tutor_id" ]
          }
        }
      }

      response "201", "pet criado com sucesso" do
        let(:pet) do
          {
            pet: {
              nome: "Rex",
              especie: "Cachorro",
              raca: "Vira-lata",
              sexo: "macho",
              data_nascimento: "2022-05-10",
              peso_atual: 12.5,
              tutor_id: tutor.id
            }
          }
        end
        run_test!
      end

      response "422", "dados inválidos" do
        let(:pet) { { pet: { nome: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/pets/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe um pet específico" do
      tags "Pets"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "pet encontrado" do
        let(:id) { pet_existente.id }
        run_test!
      end

      response "404", "pet não encontrado" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza um pet" do
      tags "Pets"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :pet, in: :body, schema: {
        type: :object,
        properties: {
          pet: {
            type: :object,
            properties: {
              nome: { type: :string },
              peso_atual: { type: :number }
            }
          }
        }
      }

      response "200", "pet atualizado com sucesso" do
        let(:id) { pet_existente.id }
        let(:pet) { { pet: { nome: "Nome Atualizado" } } }
        run_test!
      end
    end
  end
end

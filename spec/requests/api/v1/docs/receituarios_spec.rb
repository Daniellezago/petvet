require "swagger_helper"

RSpec.describe "Api::V1::Receituarios", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:veterinario) { create(:user, :veterinario, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }
  let(:receituario_existente) do
    create(:receituario, pet: pet, usuario: veterinario, crmv_responsavel: veterinario.crmv)
  end

  let(:Authorization) do
    post "/api/v1/users/sign_in",
         params: { user: { email: veterinario.email, password: senha } },
         as: :json
    response.headers["Authorization"]
  end

  path "/api/v1/receituarios" do
    get "Lista os receituários" do
      tags "Receituários"
      security [ bearer_auth: [] ]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "lista retornada com sucesso" do
        schema type: :object,
          properties: {
            receituarios: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  tipo_receituario: { type: :string, enum: [ "simples", "controle_especial" ] },
                  medicamento: { type: :string },
                  posologia: { type: :string },
                  duracao_tratamento: { type: :string, nullable: true },
                  crmv_responsavel: { type: :string },
                  data_emissao: { type: :string, format: :date },
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

    post "Cria um novo receituário" do
      tags "Receituários"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      description "Requer usuário com CRMV cadastrado (403 caso contrário). " \
                   "usuario_id e crmv_responsavel são sempre derivados do usuário " \
                   "autenticado — nunca aceitos via parâmetro, mesmo se enviados."

      parameter name: :receituario, in: :body, schema: {
        type: :object,
        properties: {
          receituario: {
            type: :object,
            properties: {
              tipo_receituario: { type: :string, enum: [ "simples", "controle_especial" ] },
              medicamento: { type: :string },
              posologia: { type: :string },
              duracao_tratamento: { type: :string },
              observacoes: { type: :string },
              data_emissao: { type: :string, format: :date },
              pet_id: { type: :integer }
            },
            required: [ "medicamento", "posologia", "data_emissao", "pet_id" ]
          }
        }
      }

      response "201", "receituário criado com sucesso" do
        let(:receituario) do
          {
            receituario: {
              medicamento: "Amoxicilina 250mg",
              posologia: "1 comprimido a cada 12 horas",
              data_emissao: Date.current,
              pet_id: pet.id
            }
          }
        end
        run_test!
      end

      response "422", "dados inválidos" do
        let(:receituario) { { receituario: { medicamento: "" } } }
        run_test!
      end
    end
  end

  path "/api/v1/receituarios/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "Exibe um receituário específico" do
      tags "Receituários"
      security [ bearer_auth: [] ]
      produces "application/json"

      response "200", "receituário encontrado" do
        let(:id) { receituario_existente.id }
        run_test!
      end

      response "404", "receituário não encontrado" do
        let(:id) { 999999 }
        run_test!
      end
    end

    patch "Atualiza um receituário" do
      tags "Receituários"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"

      parameter name: :receituario, in: :body, schema: {
        type: :object,
        properties: {
          receituario: {
            type: :object,
            properties: {
              observacoes: { type: :string }
            }
          }
        }
      }

      response "200", "receituário atualizado com sucesso" do
        let(:id) { receituario_existente.id }
        let(:receituario) { { receituario: { observacoes: "Observação atualizada" } } }
        run_test!
      end
    end
  end
end

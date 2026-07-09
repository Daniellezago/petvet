require "rails_helper"

RSpec.describe "Api::V1::Tutores", type: :request do
  let(:senha)     { "@#PetVet2026!" }
  let(:admin)     { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:atendente) { create(:user, :atendente, password: senha, password_confirmation: senha) }
  let(:tutor)     { create(:tutor) }

  # Helper para gerar token JWT (sem debug — já validado que funciona)
  def auth_headers(user)
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: senha } },
         as: :json

    { "Authorization" => response.headers["Authorization"] }
  end

  describe "GET /api/v1/tutores" do
    it "retorna lista de tutores para usuário autenticado" do
      tutor
      get "/api/v1/tutores",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(1)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/tutores", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/tutores" do
    let(:params) do
      {
        tutor: {
          nome: "João Silva",
          email: "joao@email.com",
          telefone: "11999999999",
          cpf: "123.456.789-00",
          endereco: "Rua Teste, 123"
        }
      }
    end 

    it "cria tutor com dados válidos" do
      post "/api/v1/tutores",
           params: params,
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["nome"]).to eq("João Silva")
    end

    it "retorna erros com dados inválidos" do
      post "/api/v1/tutores",
           params: { tutor: { nome: "" } },
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end
end
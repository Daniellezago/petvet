require "rails_helper"

RSpec.describe "Api::V1::Consultas", type: :request do
  let(:senha)  { "@#PetVet2026!" }
  let(:admin)  { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:outro_usuario) { create(:user, :veterinario, password: senha, password_confirmation: senha) }
  let(:tutor)  { create(:tutor) }
  let(:pet)    { create(:pet, tutor: tutor) }

  def auth_headers(user)
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: senha } },
         as: :json

    { "Authorization" => response.headers["Authorization"] }
  end

  describe "GET /api/v1/consultas" do
    it "retorna lista de consultas para usuário autenticado" do
      create_list(:consulta, 2, pet: pet, usuario: admin)

      get "/api/v1/consultas",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/consultas", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/consultas/:id" do
    it "retorna os dados da consulta" do
      consulta = create(:consulta, pet: pet, usuario: admin)

      get "/api/v1/consultas/#{consulta.id}",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["descricao"]).to eq(consulta.descricao)
    end

    it "retorna 404 se a consulta não existir" do
      get "/api/v1/consultas/999999",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/consultas" do
    let(:params_validos) do
      {
        consulta: {
          data: 1.day.ago,
          descricao: "Consulta de rotina",
          diagnostico: "Animal saudável",
          tratamento: "Nenhum",
          observacoes: "Retorno em 6 meses",
          pet_id: pet.id
        }
      }
    end

    it "cria consulta vinculada ao usuário autenticado" do
      expect {
        post "/api/v1/consultas",
             params: params_validos,
             headers: auth_headers(admin),
             as: :json
      }.to change(Consulta, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["usuario_id"]).to eq(admin.id)
    end

    it "IGNORA usuario_id enviado no corpo da requisição e usa o usuário autenticado (auditoria)" do
      post "/api/v1/consultas",
           params: params_validos.deep_merge(consulta: { usuario_id: outro_usuario.id }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)

      # Mesmo tentando "assinar" como outro_usuario, a consulta pertence a quem fez login (admin)
      expect(body["usuario_id"]).to eq(admin.id)
      expect(body["usuario_id"]).not_to eq(outro_usuario.id)
    end

    it "retorna 422 sem pet_id" do
      post "/api/v1/consultas",
           params: { consulta: params_validos[:consulta].except(:pet_id) },
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "retorna 422 com data futura" do
      post "/api/v1/consultas",
           params: params_validos.deep_merge(consulta: { data: 1.day.from_now }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "retorna 401 sem autenticação" do
      post "/api/v1/consultas", params: params_validos, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/consultas/:id" do
    it "atualiza os dados da consulta" do
      consulta = create(:consulta, pet: pet, usuario: admin, descricao: "Descrição antiga")

      patch "/api/v1/consultas/#{consulta.id}",
            params: { consulta: { descricao: "Descrição nova" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(consulta.reload.descricao).to eq("Descrição nova")
    end
  end

  describe "DELETE /api/v1/consultas/:id" do
    it "não existe rota de destroy para consultas (proteção de histórico médico)" do
      consulta = create(:consulta, pet: pet, usuario: admin)

      delete "/api/v1/consultas/#{consulta.id}",
             headers: auth_headers(admin),
             as: :json

      expect(response).to have_http_status(:not_found)
      expect(Consulta.exists?(consulta.id)).to be true
    end
  end
end

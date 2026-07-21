require "rails_helper"

RSpec.describe "Api::V1::Receituarios", type: :request do
  let(:senha)  { "@#PetVet2026!" }
  let(:veterinario) { create(:user, :veterinario, password: senha, password_confirmation: senha) }
  let(:outro_veterinario) { create(:user, :veterinario, password: senha, password_confirmation: senha) }
  let(:atendente) { create(:user, :atendente, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet)   { create(:pet, tutor: tutor) }

  def auth_headers(user)
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: senha } },
         as: :json

    { "Authorization" => response.headers["Authorization"] }
  end

  describe "GET /api/v1/receituarios" do
    it "retorna lista de receituários para usuário autenticado" do
      create_list(:receituario, 2, pet: pet, usuario: veterinario, crmv_responsavel: veterinario.crmv)

      get "/api/v1/receituarios",
          headers: auth_headers(veterinario),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/receituarios", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/receituarios/:id" do
    it "retorna os dados do receituário" do
      receituario = create(:receituario, pet: pet, usuario: veterinario, crmv_responsavel: veterinario.crmv)

      get "/api/v1/receituarios/#{receituario.id}",
          headers: auth_headers(veterinario),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["medicamento"]).to eq(receituario.medicamento)
    end

    it "retorna 404 se o receituário não existir" do
      get "/api/v1/receituarios/999999",
          headers: auth_headers(veterinario),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/receituarios" do
    let(:params_validos) do
      {
        receituario: {
          tipo_receituario: "simples",
          medicamento: "Amoxicilina 250mg",
          posologia: "1 comprimido a cada 12 horas",
          duracao_tratamento: "7 dias",
          observacoes: "Administrar com alimento",
          data_emissao: Date.current,
          pet_id: pet.id
        }
      }
    end

    it "cria receituário vinculado ao veterinário autenticado, copiando o CRMV automaticamente" do
      expect {
        post "/api/v1/receituarios",
             params: params_validos,
             headers: auth_headers(veterinario),
             as: :json
      }.to change(Receituario, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["usuario_id"]).to eq(veterinario.id)
      expect(body["crmv_responsavel"]).to eq(veterinario.crmv)
    end

    it "IGNORA usuario_id e crmv_responsavel enviados no corpo da requisição (auditoria dupla)" do
      post "/api/v1/receituarios",
           params: params_validos.deep_merge(
             receituario: { usuario_id: outro_veterinario.id, crmv_responsavel: "CRMV-FORJADO-000" }
           ),
           headers: auth_headers(veterinario),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)

      expect(body["usuario_id"]).to eq(veterinario.id)
      expect(body["crmv_responsavel"]).to eq(veterinario.crmv)
      expect(body["crmv_responsavel"]).not_to eq("CRMV-FORJADO-000")
    end

    it "retorna 403 se o usuário autenticado não for veterinário (não tem CRMV)" do
      post "/api/v1/receituarios",
           params: params_validos,
           headers: auth_headers(atendente),
           as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "retorna 422 sem pet_id" do
      post "/api/v1/receituarios",
           params: { receituario: params_validos[:receituario].except(:pet_id) },
           headers: auth_headers(veterinario),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "retorna 401 sem autenticação" do
      post "/api/v1/receituarios", params: params_validos, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/receituarios/:id" do
    it "atualiza os dados do receituário" do
      receituario = create(:receituario, pet: pet, usuario: veterinario, crmv_responsavel: veterinario.crmv, observacoes: "Observação antiga")

      patch "/api/v1/receituarios/#{receituario.id}",
            params: { receituario: { observacoes: "Observação nova" } },
            headers: auth_headers(veterinario),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(receituario.reload.observacoes).to eq("Observação nova")
    end
  end

  describe "DELETE /api/v1/receituarios/:id" do
    it "não existe rota de destroy para receituários (proteção de histórico médico)" do
      receituario = create(:receituario, pet: pet, usuario: veterinario, crmv_responsavel: veterinario.crmv)

      delete "/api/v1/receituarios/#{receituario.id}",
             headers: auth_headers(veterinario),
             as: :json

      expect(response).to have_http_status(:not_found)
      expect(Receituario.exists?(receituario.id)).to be true
    end
  end
end
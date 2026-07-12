require "rails_helper"

RSpec.describe "Api::V1::Exames", type: :request do
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

  describe "GET /api/v1/exames" do
    it "retorna lista de exames para usuário autenticado" do
      create_list(:exame, 2, pet: pet, usuario: admin)

      get "/api/v1/exames",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/exames", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/exames/:id" do
    it "retorna os dados do exame" do
      exame = create(:exame, pet: pet, usuario: admin)

      get "/api/v1/exames/#{exame.id}",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["tipo_exame"]).to eq(exame.tipo_exame)
    end

    it "retorna 404 se o exame não existir" do
      get "/api/v1/exames/999999",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/exames" do
    let(:params_validos) do
      {
        exame: {
          tipo_exame: "Hemograma completo",
          data: 1.week.ago.to_date,
          resultado: "Normal",
          observacoes: "Sem intercorrências",
          pet_id: pet.id
        }
      }
    end

    it "cria exame vinculado ao usuário autenticado" do
      expect {
        post "/api/v1/exames",
             params: params_validos,
             headers: auth_headers(admin),
             as: :json
      }.to change(Exame, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["usuario_id"]).to eq(admin.id)
    end

    it "IGNORA usuario_id enviado no corpo da requisição e usa o usuário autenticado (auditoria)" do
      post "/api/v1/exames",
           params: params_validos.deep_merge(exame: { usuario_id: outro_usuario.id }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)

      expect(body["usuario_id"]).to eq(admin.id)
      expect(body["usuario_id"]).not_to eq(outro_usuario.id)
    end

    it "retorna 422 sem pet_id" do
      post "/api/v1/exames",
           params: { exame: params_validos[:exame].except(:pet_id) },
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "retorna 422 com data futura" do
      post "/api/v1/exames",
           params: params_validos.deep_merge(exame: { data: 1.day.from_now }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "retorna 401 sem autenticação" do
      post "/api/v1/exames", params: params_validos, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/exames/:id" do
    it "atualiza os dados do exame" do
      exame = create(:exame, pet: pet, usuario: admin, resultado: "Resultado antigo")

      patch "/api/v1/exames/#{exame.id}",
            params: { exame: { resultado: "Resultado novo" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(exame.reload.resultado).to eq("Resultado novo")
    end
  end

  describe "DELETE /api/v1/exames/:id" do
    it "não existe rota de destroy para exames (proteção de histórico médico)" do
      exame = create(:exame, pet: pet, usuario: admin)

      delete "/api/v1/exames/#{exame.id}",
             headers: auth_headers(admin),
             as: :json

      expect(response).to have_http_status(:not_found)
      expect(Exame.exists?(exame.id)).to be true
    end
  end
end
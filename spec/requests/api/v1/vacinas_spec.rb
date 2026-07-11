require "rails_helper"

RSpec.describe "Api::V1::Vacinas", type: :request do
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

  describe "GET /api/v1/vacinas" do
    it "retorna lista de vacinas para usuário autenticado" do
      create_list(:vacina, 2, pet: pet, usuario: admin)

      get "/api/v1/vacinas",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/vacinas", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/vacinas/:id" do
    it "retorna os dados da vacina" do
      vacina = create(:vacina, pet: pet, usuario: admin)

      get "/api/v1/vacinas/#{vacina.id}",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["nome"]).to eq(vacina.nome)
    end

    it "retorna 404 se a vacina não existir" do
      get "/api/v1/vacinas/999999",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/vacinas" do
    let(:params_validos) do
      {
        vacina: {
          nome: "V10",
          data_aplicacao: 1.week.ago.to_date,
          proxima_dose: 1.year.from_now.to_date,
          lote: "L1234",
          fabricante: "Zoetis",
          observacoes: "Sem reações",
          pet_id: pet.id
        }
      }
    end

    it "cria vacina vinculada ao usuário autenticado" do
      expect {
        post "/api/v1/vacinas",
             params: params_validos,
             headers: auth_headers(admin),
             as: :json
      }.to change(Vacina, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["usuario_id"]).to eq(admin.id)
    end

    it "IGNORA usuario_id enviado no corpo da requisição e usa o usuário autenticado (auditoria)" do
      post "/api/v1/vacinas",
           params: params_validos.deep_merge(vacina: { usuario_id: outro_usuario.id }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)

      expect(body["usuario_id"]).to eq(admin.id)
      expect(body["usuario_id"]).not_to eq(outro_usuario.id)
    end

    it "retorna 422 sem pet_id" do
      post "/api/v1/vacinas",
           params: { vacina: params_validos[:vacina].except(:pet_id) },
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "retorna 422 com data_aplicacao futura" do
      post "/api/v1/vacinas",
           params: params_validos.deep_merge(vacina: { data_aplicacao: 1.day.from_now }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "retorna 401 sem autenticação" do
      post "/api/v1/vacinas", params: params_validos, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/vacinas/:id" do
    it "atualiza os dados da vacina" do
      vacina = create(:vacina, pet: pet, usuario: admin, lote: "Lote antigo")

      patch "/api/v1/vacinas/#{vacina.id}",
            params: { vacina: { lote: "Lote novo" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(vacina.reload.lote).to eq("Lote novo")
    end
  end

  describe "DELETE /api/v1/vacinas/:id" do
    it "não existe rota de destroy para vacinas (proteção de histórico médico)" do
      vacina = create(:vacina, pet: pet, usuario: admin)

      delete "/api/v1/vacinas/#{vacina.id}",
             headers: auth_headers(admin),
             as: :json

      expect(response).to have_http_status(:not_found)
      expect(Vacina.exists?(vacina.id)).to be true
    end
  end
end
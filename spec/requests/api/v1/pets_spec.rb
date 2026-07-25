require "rails_helper"

RSpec.describe "Api::V1::Pets", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }

  def auth_headers(user)
    post "/api/v1/users/sign_in",
        params: { user: { email: user.email, password: senha } },
        as: :json

    { "Authorization" => response.headers["Authorization"] }
  end

  # =========================================================================
  # 1. TESTES DE DELETE (Falta de Rota)
  # =========================================================================
  describe "DELETE /api/v1/pets/:id" do
    it "não existe rota de destroy para pets (proteção de histórico médico)" do
      pet = create(:pet, tutor: tutor)

      delete "/api/v1/pets/#{pet.id}",
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:not_found)
      expect(Pet.exists?(pet.id)).to be true
    end
  end

  # =========================================================================
  # 2. TESTES DE GET (INDEX / SHOW)
  # =========================================================================
  describe "GET /api/v1/pets" do
    it "retorna lista de pets para usuário autenticado" do
      create_list(:pet, 2, tutor: tutor)

      get "/api/v1/pets",
          headers: auth_headers(admin),
          as: :json

  expect(response).to have_http_status(:ok)
  body = JSON.parse(response.body)
  expect(body["pets"].length).to eq(2)
  expect(body["meta"]["total_registros"]).to eq(2)
end

    it "retorna 401 sem autenticação" do
      get "/api/v1/pets", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/pets/:id" do
    it "retorna os dados do pet" do
      pet = create(:pet, tutor: tutor)

      get "/api/v1/pets/#{pet.id}",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["nome"]).to eq(pet.nome)
    end

    it "retorna 404 se o pet não existir" do
      get "/api/v1/pets/999999",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  # =========================================================================
  # 3. TESTES DE POST (CREATE)
  # =========================================================================
  describe "POST /api/v1/pets" do
    let(:params_validos) do
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

    it "cria pet vinculado ao tutor informado" do
      expect {
        post "/api/v1/pets",
            params: params_validos,
            headers: auth_headers(admin),
            as: :json
      }.to change(Pet, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["nome"]).to eq("Rex")
      expect(body["tutor_id"]).to eq(tutor.id)
    end

    it "retorna 422 sem tutor_id" do
      post "/api/v1/pets",
          params: { pet: params_validos[:pet].except(:tutor_id) },
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "retorna 422 com dados inválidos" do
      post "/api/v1/pets",
          params: { pet: { nome: "" } },
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  # =========================================================================
  # 4. TESTES DE PATCH (UPDATE)
  # =========================================================================
  describe "PATCH /api/v1/pets/:id" do
    it "atualiza os dados do pet" do
      pet = create(:pet, tutor: tutor, nome: "Nome Antigo")

      patch "/api/v1/pets/#{pet.id}",
            params: { pet: { nome: "Nome Novo" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(pet.reload.nome).to eq("Nome Novo")
    end

    it "ignora tentativa de trocar tutor_id via update" do
      outro_tutor = create(:tutor)
      pet = create(:pet, tutor: tutor)

      patch "/api/v1/pets/#{pet.id}",
            params: { pet: { tutor_id: outro_tutor.id } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(pet.reload.tutor_id).to eq(tutor.id)
    end
  end
end

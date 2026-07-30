require "rails_helper"

RSpec.describe "Api::V1::Pesos", type: :request do
  let(:senha) { "@#PetVet2026!" }
  let(:admin) { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:tutor) { create(:tutor) }
  let(:pet) { create(:pet, tutor: tutor) }

  def auth_headers(user)
    post "/api/v1/users/sign_in", params: { user: { email: user.email, password: senha } }, as: :json
    { "Authorization" => response.headers["Authorization"] }
  end

  describe "POST /api/v1/pesos" do
    it "cria registro de peso vinculado ao usuário autenticado" do
      post "/api/v1/pesos",
          params: { peso: { data: Date.current, peso: 10.5, pet_id: pet.id } },
          headers: auth_headers(admin), as: :json

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["usuario_id"]).to eq(admin.id)
    end
  end

  describe "GET /api/v1/pesos" do
    it "retorna lista paginada" do
      create_list(:peso, 2, pet: pet, usuario: admin)
      get "/api/v1/pesos", headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["pesos"].length).to eq(2)
    end
  end
end

require "rails_helper"

RSpec.describe "Api::V1::Contratos", type: :request do
  let(:senha)  { "@#PetVet2026!" }
  let(:admin)  { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:atendente) { create(:user, :atendente, password: senha, password_confirmation: senha) }
  let(:tutor)  { create(:tutor) }
  let(:pet)    { create(:pet, tutor: tutor) }

  def auth_headers(user)
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: senha } },
         as: :json

    { "Authorization" => response.headers["Authorization"] }
  end

  describe "GET /api/v1/contratos" do
    it "retorna lista de contratos para usuário autenticado" do
      create_list(:contrato, 2, tutor: tutor, pet: pet)

      get "/api/v1/contratos",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/contratos", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/contratos/:id" do
    it "retorna os dados do contrato" do
      contrato = create(:contrato, :convenio, tutor: tutor, pet: pet)

      get "/api/v1/contratos/#{contrato.id}",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["numero_carteirinha"]).to eq(contrato.numero_carteirinha)
    end

    it "retorna 404 se o contrato não existir" do
      get "/api/v1/contratos/999999",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/contratos" do
    let(:params_particular) do
      {
        contrato: {
          tipo_contrato: "particular",
          data_inicio: Date.current,
          tutor_id: tutor.id,
          pet_id: pet.id
        }
      }
    end

    let(:params_convenio) do
      {
        contrato: {
          tipo_contrato: "convenio",
          nome_convenio: "PetLove",
          numero_carteirinha: "CARD-12345",
          percentual_cobertura: 80.0,
          data_inicio: Date.current,
          tutor_id: tutor.id,
          pet_id: pet.id
        }
      }
    end

    it "cria contrato particular sem exigir campos de convênio" do
      expect {
        post "/api/v1/contratos",
             params: params_particular,
             headers: auth_headers(admin),
             as: :json
      }.to change(Contrato, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "cria contrato de convênio com carteirinha e percentual de cobertura" do
      post "/api/v1/contratos",
           params: params_convenio,
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["numero_carteirinha"]).to eq("CARD-12345")
      expect(body["percentual_cobertura"].to_f).to eq(80.0)
    end

    it "retorna 422 se convênio não tiver numero_carteirinha" do
      post "/api/v1/contratos",
           params: params_convenio.deep_merge(contrato: { numero_carteirinha: "" }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).to include("Numero carteirinha é obrigatório para contratos de convênio")
    end

    it "retorna 422 se o pet não pertencer ao tutor informado" do
      outro_tutor = create(:tutor)
      pet_de_outro_tutor = create(:pet, tutor: outro_tutor)

      post "/api/v1/contratos",
           params: params_particular.deep_merge(contrato: { pet_id: pet_de_outro_tutor.id }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).to include("Pet deve pertencer ao tutor informado")
    end

    it "retorna 401 sem autenticação" do
      post "/api/v1/contratos", params: params_particular, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/contratos/:id" do
    it "atualiza os dados do contrato" do
      contrato = create(:contrato, :convenio, tutor: tutor, pet: pet, percentual_cobertura: 70.0)

      patch "/api/v1/contratos/#{contrato.id}",
            params: { contrato: { percentual_cobertura: 90.0 } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(contrato.reload.percentual_cobertura.to_f).to eq(90.0)
    end
  end

  describe "DELETE /api/v1/contratos/:id" do
    context "quando admin" do
      it "remove o contrato de verdade" do
        contrato = create(:contrato, tutor: tutor, pet: pet)

        expect {
          delete "/api/v1/contratos/#{contrato.id}",
                 headers: auth_headers(admin),
                 as: :json
        }.to change(Contrato, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "quando atendente (sem permissão)" do
      it "retorna 403 e não remove o contrato" do
        contrato = create(:contrato, tutor: tutor, pet: pet)

        expect {
          delete "/api/v1/contratos/#{contrato.id}",
                 headers: auth_headers(atendente),
                 as: :json
        }.not_to change(Contrato, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "cenário real: múltiplos pets do mesmo tutor com convênios diferentes" do
    it "permite consultar contratos distintos por pet, mesmo tutor" do
      mia = create(:pet, tutor: tutor, nome: "Mia")
      luna = create(:pet, tutor: tutor, nome: "Luna")

      create(:contrato, :convenio, tutor: tutor, pet: mia, numero_carteirinha: "CARD-MIA")
      create(:contrato, :convenio, tutor: tutor, pet: luna, numero_carteirinha: "CARD-LUNA")

      get "/api/v1/contratos",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      carteirinhas = body.map { |c| c["numero_carteirinha"] }

      expect(carteirinhas).to contain_exactly("CARD-MIA", "CARD-LUNA")
    end
  end
end
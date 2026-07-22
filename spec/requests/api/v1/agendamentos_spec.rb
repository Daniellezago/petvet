require "rails_helper"

RSpec.describe "Api::V1::Agendamentos", type: :request do
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

  describe "GET /api/v1/agendamentos" do
    it "retorna lista de agendamentos para usuário autenticado" do
      create_list(:agendamento, 2, tutor: tutor, pet: pet, usuario: admin)

      get "/api/v1/agendamentos",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end

    it "retorna 401 sem autenticação" do
      get "/api/v1/agendamentos", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/agendamentos/:id" do
    it "retorna os dados do agendamento" do
      agendamento = create(:agendamento, tutor: tutor, pet: pet, usuario: admin)

      get "/api/v1/agendamentos/#{agendamento.id}",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(agendamento.id)
    end

    it "retorna 404 se o agendamento não existir" do
      get "/api/v1/agendamentos/999999",
          headers: auth_headers(admin),
          as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/agendamentos" do
    let(:params_validos) do
      {
        agendamento: {
          data_hora: 1.day.from_now,
          observacoes: "Consulta de rotina",
          tutor_id: tutor.id,
          pet_id: pet.id
        }
      }
    end

    it "cria agendamento vinculado ao usuário autenticado" do
      expect {
        post "/api/v1/agendamentos",
             params: params_validos,
             headers: auth_headers(admin),
             as: :json
      }.to change(Agendamento, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["usuario_id"]).to eq(admin.id)
      expect(body["status"]).to eq("agendado")
    end

    it "IGNORA usuario_id enviado no corpo da requisição e usa o usuário autenticado (auditoria)" do
      outro_usuario = create(:user, :veterinario)

      post "/api/v1/agendamentos",
           params: params_validos.deep_merge(agendamento: { usuario_id: outro_usuario.id }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["usuario_id"]).to eq(admin.id)
    end

    it "retorna 422 se o pet não pertencer ao tutor informado" do
      outro_tutor = create(:tutor)
      pet_de_outro_tutor = create(:pet, tutor: outro_tutor)

      post "/api/v1/agendamentos",
           params: params_validos.deep_merge(agendamento: { pet_id: pet_de_outro_tutor.id }),
           headers: auth_headers(admin),
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).to include("Pet deve pertencer ao tutor informado")
    end

    it "retorna 401 sem autenticação" do
      post "/api/v1/agendamentos", params: params_validos, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /api/v1/agendamentos/:id" do
    it "atualiza o status do agendamento" do
      agendamento = create(:agendamento, tutor: tutor, pet: pet, usuario: admin)

      patch "/api/v1/agendamentos/#{agendamento.id}",
            params: { agendamento: { status: "confirmado" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(agendamento.reload.status).to eq("confirmado")
    end
  end

  describe "DELETE /api/v1/agendamentos/:id" do
    context "quando admin" do
      it "remove o agendamento de verdade" do
        agendamento = create(:agendamento, tutor: tutor, pet: pet, usuario: admin)

        expect {
          delete "/api/v1/agendamentos/#{agendamento.id}",
                 headers: auth_headers(admin),
                 as: :json
        }.to change(Agendamento, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "quando atendente (sem permissão)" do
      it "retorna 403 e não remove o agendamento" do
        agendamento = create(:agendamento, tutor: tutor, pet: pet, usuario: admin)

        expect {
          delete "/api/v1/agendamentos/#{agendamento.id}",
                 headers: auth_headers(atendente),
                 as: :json
        }.not_to change(Agendamento, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end

    it "retorna 401 sem autenticação" do
      agendamento = create(:agendamento, tutor: tutor, pet: pet, usuario: admin)

      delete "/api/v1/agendamentos/#{agendamento.id}", as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
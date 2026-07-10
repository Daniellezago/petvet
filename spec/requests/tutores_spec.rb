require "rails_helper"

RSpec.describe "Api::V1::Tutores", type: :request do
  let(:senha) { "@#PetVet2026!" }

  let(:admin) do
    create(:user, :admin, password: senha, password_confirmation: senha)
  end

  let(:atendente) do
    create(:user, :atendente, password: senha, password_confirmation: senha)
  end

  # Helper: faz login via API e devolve o header Authorization pronto
  def auth_headers(user)
    post "/api/v1/users/sign_in",
         params: { user: { email: user.email, password: senha } },
         as: :json

    { "Authorization" => response.headers["Authorization"] }
  end

  describe "GET /api/v1/tutores" do
    context "quando autenticado" do
      it "retorna 200 e a lista de tutores ativos" do
        create_list(:tutor, 3)
        headers = auth_headers(admin)

        get "/api/v1/tutores", headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.size).to eq(3)
      end
    end

    context "quando não autenticado" do
      it "retorna 401" do
        get "/api/v1/tutores", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/tutores/:id" do
    it "retorna 200 e os dados do tutor" do
      tutor = create(:tutor)
      headers = auth_headers(admin)

      get "/api/v1/tutores/#{tutor.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(tutor.id)
    end

    it "retorna 404 se o tutor não existir" do
      headers = auth_headers(admin)

      get "/api/v1/tutores/999999", headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/tutores" do
    let(:params_validos) do
      {
        tutor: {
          nome: "Maria Silva",
          cpf: "123.456.789-00",
          email: "maria@example.com",
          telefone: "11999999999"
        }
      }
    end

    it "cria um tutor com dados válidos" do
      headers = auth_headers(admin)

      expect {
        post "/api/v1/tutores", params: params_validos, headers: headers, as: :json
      }.to change(Tutor, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "retorna 422 com dados inválidos" do
      headers = auth_headers(admin)

      post "/api/v1/tutores",
           params: { tutor: { nome: "", cpf: "", email: "" } },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "permite recadastrar CPF/email já usados por um tutor inativo (soft delete)" do
      tutor_antigo = create(:tutor, cpf: "123.456.789-00", email: "maria@example.com")
      tutor_antigo.update!(ativo: false)
      headers = auth_headers(admin)

      expect {
        post "/api/v1/tutores", params: params_validos, headers: headers, as: :json
      }.to change(Tutor, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "bloqueia CPF/email duplicado se o tutor original estiver ativo" do
      create(:tutor, cpf: "123.456.789-00", email: "maria@example.com")
      headers = auth_headers(admin)

      post "/api/v1/tutores", params: params_validos, headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/tutores/:id" do
    it "atualiza os dados do tutor" do
      tutor = create(:tutor, nome: "Nome Antigo")
      headers = auth_headers(admin)

      patch "/api/v1/tutores/#{tutor.id}",
            params: { tutor: { nome: "Nome Novo" } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(tutor.reload.nome).to eq("Nome Novo")
    end
  end

  describe "DELETE /api/v1/tutores/:id (soft delete)" do
    context "quando admin" do
      it "inativa o tutor em vez de destruir o registro" do
        tutor = create(:tutor, ativo: true)
        headers = auth_headers(admin)

        expect {
          delete "/api/v1/tutores/#{tutor.id}", headers: headers, as: :json
        }.not_to change(Tutor.unscoped, :count)

        expect(response).to have_http_status(:no_content)
        expect(tutor.reload.ativo).to be false
      end
    end

    context "quando atendente (sem permissão)" do
      it "retorna 403" do
        tutor = create(:tutor, ativo: true)
        headers = auth_headers(atendente)

        delete "/api/v1/tutores/#{tutor.id}", headers: headers, as: :json

        expect(response).to have_http_status(:forbidden)
        expect(tutor.reload.ativo).to be true
      end
    end
  end
end
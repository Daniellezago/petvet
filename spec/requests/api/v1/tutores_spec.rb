require "rails_helper"

RSpec.describe "Api::V1::Tutores", type: :request do
  let(:senha)     { "@#PetVet2026!" }
  let(:admin)     { create(:user, :admin, password: senha, password_confirmation: senha) }
  let(:atendente) { create(:user, :atendente, password: senha, password_confirmation: senha) }
  let(:tutor)     { create(:tutor) }

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

  describe "PATCH /api/v1/tutores/:id" do
    it "atualiza os dados do tutor autenticado" do
      tutor_existente = create(:tutor, nome: "Nome Antigo")

      patch "/api/v1/tutores/#{tutor_existente.id}",
            params: { tutor: { nome: "Nome Novo" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["nome"]).to eq("Nome Novo")
      expect(tutor_existente.reload.nome).to eq("Nome Novo")
    end

    it "retorna 422 ao atualizar com dados inválidos" do
      tutor_existente = create(:tutor)

      patch "/api/v1/tutores/#{tutor_existente.id}",
            params: { tutor: { email: "" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to have_key("errors")
    end

    it "retorna 401 sem autenticação" do
      tutor_existente = create(:tutor)

      patch "/api/v1/tutores/#{tutor_existente.id}",
            params: { tutor: { nome: "Tentativa Sem Login" } },
            as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 404 se o tutor não existir" do
      patch "/api/v1/tutores/999999",
            params: { tutor: { nome: "Fantasma" } },
            headers: auth_headers(admin),
            as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/tutores/:id (soft delete)" do
    context "quando admin" do
      it "inativa o tutor em vez de destruir o registro" do
        tutor_existente = create(:tutor, ativo: true)

        expect {
          delete "/api/v1/tutores/#{tutor_existente.id}",
                 headers: auth_headers(admin),
                 as: :json
        }.not_to change(Tutor.unscoped, :count)

        expect(response).to have_http_status(:no_content)
        expect(tutor_existente.reload.ativo).to be false
      end
    end

    context "quando atendente (sem permissão)" do
      it "retorna 403 e não altera o tutor" do
        tutor_existente = create(:tutor, ativo: true)

        delete "/api/v1/tutores/#{tutor_existente.id}",
               headers: auth_headers(atendente),
               as: :json

        expect(response).to have_http_status(:forbidden)
        expect(tutor_existente.reload.ativo).to be true
      end
    end

    context "sem autenticação" do
      it "retorna 401" do
        tutor_existente = create(:tutor, ativo: true)

        delete "/api/v1/tutores/#{tutor_existente.id}", as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(tutor_existente.reload.ativo).to be true
      end
    end

    it "retorna 404 se o tutor não existir" do
      delete "/api/v1/tutores/999999",
             headers: auth_headers(admin),
             as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
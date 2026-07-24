require "rails_helper"

RSpec.describe "Health check", type: :request do
  it "retorna 200 em /up, sem exigir autenticação" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end
end
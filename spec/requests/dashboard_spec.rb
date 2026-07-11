require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    it "redireciona para login quando não autenticado" do
      get "/dashboard/index"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

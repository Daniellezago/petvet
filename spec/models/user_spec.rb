require "rails_helper"

RSpec.describe User, type: :model do
  # Define o sujeito do teste usando o FactoryBot para que o Shoulda Matchers
  # consiga criar um registro prévio no banco antes de testar a unicidade.
  subject { create(:user) }

  # Testa validações de presença
  it { should validate_presence_of(:email_address) }
  it { should validate_presence_of(:role) }

  it { should validate_uniqueness_of(:email_address).case_insensitive }

  # Testa que role deve ser um dos valores válidos
  it { should validate_inclusion_of(:role).in_array(%w[admin veterinario atendente]) }

  # Testa os métodos de conveniência
  describe "#admin?" do
    it "retorna true quando role é admin" do
      user = User.new(role: "admin")
      expect(user.admin?).to be true
    end

    it "retorna false quando role não é admin" do
      user = User.new(role: "atendente")
      expect(user.admin?).to be false
    end
  end

  describe "#veterinario?" do
    it "retorna true quando role é veterinario" do
      user = User.new(role: "veterinario")
      expect(user.veterinario?).to be true
    end
  end
end

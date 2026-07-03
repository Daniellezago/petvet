require "rails_helper"

RSpec.describe User, type: :model do
  # Validações
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:role) }
  it { should validate_inclusion_of(:role).in_array(%w[admin veterinario atendente]) }

  describe "email único" do
    it "não permite dois usuários com o mesmo email" do
      create(:user, email: "teste@petvet.com")
      duplicado = build(:user, email: "teste@petvet.com")
      expect(duplicado).not_to be_valid
    end
  end

  describe "role padrão" do
    it "nasce como atendente" do
      user = create(:user)
      expect(user.role).to eq("atendente")
    end
  end

  describe "soft delete" do
    it "nasce como ativo" do
      user = create(:user)
      expect(user.ativo).to be true
    end

    it "pode ser inativado sem apagar do banco" do
      user = create(:user)
      user.update(ativo: false)
      expect(User.find(user.id).ativo).to be false
    end
  end

  describe "#admin?" do
    it "retorna true quando role é admin" do
      user = build(:user, role: "admin")
      expect(user.admin?).to be true
    end

    it "retorna false quando role não é admin" do
      user = build(:user, role: "atendente")
      expect(user.admin?).to be false
    end
  end

  describe "#veterinario?" do
    it "retorna true quando role é veterinario" do
      user = build(:user, role: "veterinario")
      expect(user.veterinario?).to be true
    end

    it "retorna false quando role não é veterinario" do
      user = build(:user, role: "atendente")
      expect(user.veterinario?).to be false
    end
  end

  describe "#atendente?" do
    it "retorna true quando role é atendente" do
      user = build(:user, role: "atendente")
      expect(user.atendente?).to be true
    end
  end
end

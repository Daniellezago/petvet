require "rails_helper"

RSpec.describe Tutor, type: :model do
  # Validações de presença
  it { should validate_presence_of(:nome) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:cpf) }
  it { should validate_presence_of(:telefone) }

  # Validações de unicidade
  describe "unicidade" do
    it "não permite dois tutores com o mesmo email" do
      create(:tutor, email: "maria@email.com")
      duplicado = build(:tutor, email: "maria@email.com")
      expect(duplicado).not_to be_valid
    end

    it "não permite dois tutores com o mesmo cpf" do
      tutor = create(:tutor)
      duplicado = build(:tutor, cpf: tutor.cpf)
      expect(duplicado).not_to be_valid
    end
  end

  # Soft delete
  describe "soft delete" do
    it "não apaga do banco, só marca deleted_at" do
      tutor = create(:tutor)
      tutor.destroy
      expect(Tutor.only_deleted.find(tutor.id)).to be_present
    end
  end

  # Relacionamentos
  describe "relacionamentos" do
    
  end

  # Normalização de email
  describe "normalização" do
    it "salva email em minúsculo" do
      tutor = create(:tutor, email: "MARIA@EMAIL.COM")
      expect(tutor.email).to eq("maria@email.com")
    end
  end
end
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


  describe "soft delete" do
    it "permite marcar o tutor como inativo sem removê-lo do banco" do
      tutor = create(:tutor)
      tutor.update!(ativo: false)

      expect(Tutor.exists?(tutor.id)).to be true
      expect(tutor.reload.ativo).to be false
    end

    it "não retorna tutores inativos no scope :ativos" do
      ativo = create(:tutor, ativo: true)
      inativo = create(:tutor, ativo: false)

      expect(Tutor.ativos).to include(ativo)
      expect(Tutor.ativos).not_to include(inativo)
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

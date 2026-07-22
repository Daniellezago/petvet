require "rails_helper"

RSpec.describe Contrato, type: :model do
  describe "associações" do
    it { should belong_to(:tutor) }
    it { should belong_to(:pet) }
  end

  describe "validações" do
    it { should validate_presence_of(:data_inicio) }

    it "é inválido se o pet não pertencer ao tutor informado" do
      tutor_a = create(:tutor)
      tutor_b = create(:tutor)
      pet_do_tutor_b = create(:pet, tutor: tutor_b)

      contrato = build(:contrato, tutor: tutor_a, pet: pet_do_tutor_b)

      expect(contrato).not_to be_valid
      expect(contrato.errors[:pet]).to include("deve pertencer ao tutor informado")
    end

    it "é válido se o pet pertencer ao tutor informado" do
      tutor = create(:tutor)
      pet = create(:pet, tutor: tutor)

      contrato = build(:contrato, tutor: tutor, pet: pet)

      expect(contrato).to be_valid
    end
  end

  describe "regras de convênio" do
    it "é válido do tipo particular sem nenhum campo de convênio preenchido" do
      contrato = build(:contrato, tipo_contrato: :particular)
      expect(contrato).to be_valid
    end

    it "é inválido do tipo convênio sem nome_convenio" do
      contrato = build(:contrato, :convenio, nome_convenio: nil)

      expect(contrato).not_to be_valid
      expect(contrato.errors[:nome_convenio]).to include("é obrigatório para contratos de convênio")
    end

    it "é inválido do tipo convênio sem numero_carteirinha" do
      contrato = build(:contrato, :convenio, numero_carteirinha: nil)

      expect(contrato).not_to be_valid
      expect(contrato.errors[:numero_carteirinha]).to include("é obrigatório para contratos de convênio")
    end

    it "é inválido do tipo convênio sem percentual_cobertura" do
      contrato = build(:contrato, :convenio, percentual_cobertura: nil)

      expect(contrato).not_to be_valid
      expect(contrato.errors[:percentual_cobertura]).to include("é obrigatório para contratos de convênio")
    end

    it "é válido do tipo convênio com todos os campos preenchidos" do
      contrato = build(:contrato, :convenio)
      expect(contrato).to be_valid
    end

    it "é inválido com percentual_cobertura acima de 100" do
      contrato = build(:contrato, :convenio, percentual_cobertura: 150)

      expect(contrato).not_to be_valid
      expect(contrato.errors[:percentual_cobertura]).to include("deve estar entre 0 e 100")
    end

    it "é inválido com percentual_cobertura negativo" do
      contrato = build(:contrato, :convenio, percentual_cobertura: -10)

      expect(contrato).not_to be_valid
      expect(contrato.errors[:percentual_cobertura]).to include("deve estar entre 0 e 100")
    end
  end

  describe "múltiplos contratos por tutor" do
    it "permite que um tutor tenha contratos diferentes para pets diferentes" do
      tutor = create(:tutor)
      mia = create(:pet, tutor: tutor, nome: "Mia")
      luna = create(:pet, tutor: tutor, nome: "Luna")

      contrato_mia = create(:contrato, :convenio, tutor: tutor, pet: mia, numero_carteirinha: "CARD-MIA")
      contrato_luna = create(:contrato, :convenio, tutor: tutor, pet: luna, numero_carteirinha: "CARD-LUNA")

      expect(tutor.contratos).to include(contrato_mia, contrato_luna)
      expect(contrato_mia.numero_carteirinha).not_to eq(contrato_luna.numero_carteirinha)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:contrato)).to be_valid
    end
  end
end

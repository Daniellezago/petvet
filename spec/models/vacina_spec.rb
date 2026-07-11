require "rails_helper"

RSpec.describe Vacina, type: :model do
  describe "associações" do
    it { should belong_to(:pet) }
    it { should belong_to(:usuario).class_name("User") }
  end

  describe "validações" do
    it { should validate_presence_of(:nome) }
    it { should validate_presence_of(:data_aplicacao) }

    it "é inválida com data_aplicacao no futuro" do
      vacina = build(:vacina, data_aplicacao: 1.day.from_now)
      expect(vacina).not_to be_valid
      expect(vacina.errors[:data_aplicacao]).to include("não pode ser uma data futura")
    end

    it "é válida com data_aplicacao no passado" do
      vacina = build(:vacina, data_aplicacao: 1.day.ago)
      expect(vacina).to be_valid
    end

    it "é inválida se proxima_dose for antes ou igual à data_aplicacao" do
      vacina = build(:vacina, data_aplicacao: Date.current, proxima_dose: Date.current)
      expect(vacina).not_to be_valid
      expect(vacina.errors[:proxima_dose]).to include("deve ser uma data posterior à data de aplicação")
    end

    it "é válida se proxima_dose for depois da data_aplicacao" do
      vacina = build(:vacina, data_aplicacao: Date.current, proxima_dose: 1.month.from_now.to_date)
      expect(vacina).to be_valid
    end

    it "permite proxima_dose em branco" do
      vacina = build(:vacina, proxima_dose: nil)
      expect(vacina).to be_valid
    end
  end

  describe "proteção contra destroy" do
    it "não permite destruir uma vacina, mesmo diretamente no model" do
      vacina = create(:vacina)

      expect { vacina.destroy }.not_to change(Vacina, :count)
      expect(vacina.destroyed?).to be false
    end

    it "não permite destroy! (versão que lança exceção)" do
      vacina = create(:vacina)

      expect { vacina.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:vacina)).to be_valid
    end
  end
end

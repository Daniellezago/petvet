require "rails_helper"

RSpec.describe Consulta, type: :model do
  describe "associações" do
    it { should belong_to(:pet) }
    it { should belong_to(:usuario).class_name("User") }
  end

  describe "validações" do
    it { should validate_presence_of(:data) }
    it { should validate_presence_of(:descricao) }

    it "é inválida com data no futuro" do
      consulta = build(:consulta, data: 1.day.from_now)
      expect(consulta).not_to be_valid
      expect(consulta.errors[:data]).to include("não pode ser uma data futura")
    end

    it "é válida com data no passado" do
      consulta = build(:consulta, data: 1.day.ago)
      expect(consulta).to be_valid
    end
  end

  describe "proteção contra destroy" do
    it "não permite destruir uma consulta, mesmo diretamente no model" do
      consulta = create(:consulta)

      expect { consulta.destroy }.not_to change(Consulta, :count)
      expect(consulta.destroyed?).to be false
    end

    it "não permite destroy! (versão que lança exceção)" do
      consulta = create(:consulta)

      expect { consulta.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:consulta)).to be_valid
    end
  end
end

require "rails_helper"

RSpec.describe Peso, type: :model do
  describe "associações" do
    it { should belong_to(:pet) }
    it { should belong_to(:usuario).class_name("User") }
  end

  describe "validações" do
    it { should validate_presence_of(:data) }
    it { should validate_presence_of(:peso) }

    it "é inválido com peso menor ou igual a zero" do
      peso = build(:peso, peso: 0)
      expect(peso).not_to be_valid
    end

    it "é inválido com data futura" do
      peso = build(:peso, data: 1.day.from_now)
      expect(peso).not_to be_valid
    end
  end

  describe "proteção contra destroy" do
    it "não permite destruir um registro de peso" do
      peso = create(:peso)
      expect { peso.destroy }.not_to change(Peso, :count)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:peso)).to be_valid
    end
  end
end

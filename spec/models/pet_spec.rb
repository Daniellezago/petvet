require "rails_helper"

RSpec.describe Pet, type: :model do
  describe "associações" do
    it { should belong_to(:tutor) }
  end

  describe "validações" do
    it { should validate_presence_of(:nome) }
    it { should validate_presence_of(:especie) }
    it { should validate_presence_of(:sexo) }

    it "é inválido com peso_atual menor ou igual a zero" do
      pet = build(:pet, peso_atual: 0)
      expect(pet).not_to be_valid
      expect(pet.errors[:peso_atual]).to be_present
    end

    it "permite peso_atual em branco" do
      pet = build(:pet, peso_atual: nil)
      expect(pet).to be_valid
    end

    it "é inválido com data_nascimento no futuro" do
      pet = build(:pet, data_nascimento: 1.day.from_now)
      expect(pet).not_to be_valid
      expect(pet.errors[:data_nascimento]).to include("não pode ser uma data futura")
    end

    it "é válido com data_nascimento no passado" do
      pet = build(:pet, data_nascimento: 2.years.ago)
      expect(pet).to be_valid
    end
  end

  describe "enum sexo" do
    it "aceita macho e femea como valores válidos" do
      expect(Pet.sexos.keys).to contain_exactly("macho", "femea")
    end

    it "permite consultar via scope gerado pelo enum" do
      pet_macho = create(:pet, sexo: :macho)
      pet_femea = create(:pet, sexo: :femea)

      expect(Pet.macho).to include(pet_macho)
      expect(Pet.macho).not_to include(pet_femea)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:pet)).to be_valid
    end
  end

  describe "proteção contra destroy" do
    it "não permite destruir um pet, mesmo diretamente no model" do
      pet = create(:pet)

      expect { pet.destroy }.not_to change(Pet, :count)
      expect(pet.destroyed?).to be false
    end

    it "adiciona mensagem de erro ao tentar destruir" do
      pet = create(:pet)
      pet.destroy

      expect(pet.errors[:base]).to include("Pets não podem ser removidos: histórico médico é permanente")
    end

    it "não permite destroy! (versão que lança exceção)" do
      pet = create(:pet)

      expect { pet.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end
end
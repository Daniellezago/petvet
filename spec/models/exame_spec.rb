require "rails_helper"

RSpec.describe Exame, type: :model do
  describe "associações" do
    it { should belong_to(:pet) }
    it { should belong_to(:usuario).class_name("User") }
  end

  describe "validações" do
    it { should validate_presence_of(:tipo_exame) }
    it { should validate_presence_of(:data) }

    it "é inválido com data no futuro" do
      exame = build(:exame, data: 1.day.from_now)
      expect(exame).not_to be_valid
      expect(exame.errors[:data]).to include("não pode ser uma data futura")
    end

    it "é válido com data no passado" do
      exame = build(:exame, data: 1.day.ago)
      expect(exame).to be_valid
    end
  end

  describe "proteção contra destroy" do
    it "não permite destruir um exame, mesmo diretamente no model" do
      exame = create(:exame)

      expect { exame.destroy }.not_to change(Exame, :count)
      expect(exame.destroyed?).to be false
    end

    it "não permite destroy! (versão que lança exceção)" do
      exame = create(:exame)

      expect { exame.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:exame)).to be_valid
    end
  end
end
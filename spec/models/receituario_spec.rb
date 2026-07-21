require "rails_helper"

RSpec.describe Receituario, type: :model do
  describe "associações" do
    it { should belong_to(:pet) }
    it { should belong_to(:usuario).class_name("User") }
  end

  describe "validações" do
    it { should validate_presence_of(:medicamento) }
    it { should validate_presence_of(:posologia) }
    it { should validate_presence_of(:crmv_responsavel) }
    it { should validate_presence_of(:data_emissao) }

    it "é inválido com data_emissao no futuro" do
      receituario = build(:receituario, data_emissao: 1.day.from_now)
      expect(receituario).not_to be_valid
      expect(receituario.errors[:data_emissao]).to include("não pode ser uma data futura")
    end

    it "é válido com data_emissao no passado" do
      receituario = build(:receituario, data_emissao: 1.day.ago)
      expect(receituario).to be_valid
    end

    it "é inválido se o usuário responsável não tiver CRMV cadastrado" do
      usuario_sem_crmv = create(:user, :atendente)
      receituario = build(:receituario, usuario: usuario_sem_crmv)

      expect(receituario).not_to be_valid
      expect(receituario.errors[:usuario]).to include("precisa ter um CRMV cadastrado para emitir receituário")
    end

    it "é válido se o usuário responsável tiver CRMV cadastrado" do
      veterinario = create(:user, :veterinario)
      receituario = build(:receituario, usuario: veterinario, crmv_responsavel: veterinario.crmv)

      expect(receituario).to be_valid
    end
  end

  describe "enum tipo_receituario" do
    it "assume 'simples' como padrão" do
      receituario = create(:receituario)
      expect(receituario.simples?).to be true
    end

    it "permite marcar como controle_especial" do
      receituario = create(:receituario, :controle_especial)
      expect(receituario.controle_especial?).to be true
    end
  end

  describe "proteção contra destroy" do
    it "não permite destruir um receituário, mesmo diretamente no model" do
      receituario = create(:receituario)

      expect { receituario.destroy }.not_to change(Receituario, :count)
      expect(receituario.destroyed?).to be false
    end

    it "não permite destroy! (versão que lança exceção)" do
      receituario = create(:receituario)

      expect { receituario.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:receituario)).to be_valid
    end
  end
end
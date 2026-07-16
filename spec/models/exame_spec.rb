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

  describe "upload de arquivo" do
    it "é válido sem nenhum arquivo anexado" do
      exame = build(:exame)
      expect(exame).to be_valid
    end

    it "aceita um arquivo PDF" do
      exame = build(:exame)
      exame.arquivo.attach(
        io: StringIO.new("conteúdo fake de pdf"),
        filename: "laudo.pdf",
        content_type: "application/pdf"
      )

      expect(exame).to be_valid
    end

    it "aceita uma imagem JPEG" do
      exame = build(:exame)
      exame.arquivo.attach(
        io: StringIO.new("conteúdo fake de imagem"),
        filename: "laudo.jpg",
        content_type: "image/jpeg"
      )

      expect(exame).to be_valid
    end

    it "aceita uma imagem PNG" do
      exame = build(:exame)
      exame.arquivo.attach(
        io: StringIO.new("conteúdo fake de imagem"),
        filename: "laudo.png",
        content_type: "image/png"
      )

      expect(exame).to be_valid
    end

    it "rejeita um arquivo de texto (.txt)" do
      exame = build(:exame)
      exame.arquivo.attach(
        io: StringIO.new("isso não é um laudo válido"),
        filename: "laudo.txt",
        content_type: "text/plain"
      )

      expect(exame).not_to be_valid
      expect(exame.errors[:arquivo]).to include("deve ser um arquivo PDF, JPEG ou PNG")
    end

    it "rejeita um arquivo executável disfarçado (proteção de segurança)" do
      exame = build(:exame)
      exame.arquivo.attach(
        io: StringIO.new("conteúdo malicioso simulado"),
        filename: "virus.exe",
        content_type: "application/x-msdownload"
      )

      expect(exame).not_to be_valid
      expect(exame.errors[:arquivo]).to include("deve ser um arquivo PDF, JPEG ou PNG")
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
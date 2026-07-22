require "rails_helper"

RSpec.describe Agendamento, type: :model do
  describe "associações" do
    it { should belong_to(:tutor) }
    it { should belong_to(:pet) }
    it { should belong_to(:usuario).class_name("User") }
  end

  describe "validações" do
    it { should validate_presence_of(:data_hora) }

    it "é inválido se o pet não pertencer ao tutor informado" do
      tutor_a = create(:tutor)
      tutor_b = create(:tutor)
      pet_do_tutor_b = create(:pet, tutor: tutor_b)

      agendamento = build(:agendamento, tutor: tutor_a, pet: pet_do_tutor_b)

      expect(agendamento).not_to be_valid
      expect(agendamento.errors[:pet]).to include("deve pertencer ao tutor informado")
    end

    it "é válido se o pet pertencer ao tutor informado" do
      tutor = create(:tutor)
      pet = create(:pet, tutor: tutor)

      agendamento = build(:agendamento, tutor: tutor, pet: pet)

      expect(agendamento).to be_valid
    end
  end

  describe "enum status" do
    it "assume 'agendado' como padrão" do
      agendamento = create(:agendamento)
      expect(agendamento.agendado?).to be true
    end

    it "permite marcar como confirmado" do
      agendamento = create(:agendamento, :confirmado)
      expect(agendamento.confirmado?).to be true
    end

    it "permite marcar como cancelado" do
      agendamento = create(:agendamento, :cancelado)
      expect(agendamento.cancelado?).to be true
    end
  end

  describe "factory" do
    it "tem uma factory válida" do
      expect(build(:agendamento)).to be_valid
    end
  end
end

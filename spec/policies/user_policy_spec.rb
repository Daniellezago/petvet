require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin)      { create(:user, :admin) }
  let(:veterinario) { create(:user, :veterinario) }
  let(:atendente)  { create(:user, :atendente) }
  let(:outro_user) { create(:user) }

  subject { described_class }

  describe "index?" do
    it "permite admin" do
      expect(subject.new(admin, User)).to permit_action(:index)
    end

    it "bloqueia veterinário" do
      expect(subject.new(veterinario, User)).not_to permit_action(:index)
    end

    it "bloqueia atendente" do
      expect(subject.new(atendente, User)).not_to permit_action(:index)
    end
  end

  describe "create?" do
    it "permite admin" do
      expect(subject.new(admin, User)).to permit_action(:create)
    end

    it "bloqueia veterinário" do
      expect(subject.new(veterinario, User)).not_to permit_action(:create)
    end

    it "bloqueia atendente" do
      expect(subject.new(atendente, User)).not_to permit_action(:create)
    end
  end

  describe "destroy?" do
    it "bloqueia todos — nunca apaga usuário" do
      expect(subject.new(admin, User)).not_to permit_action(:destroy)
      expect(subject.new(veterinario, User)).not_to permit_action(:destroy)
      expect(subject.new(atendente, User)).not_to permit_action(:destroy)
    end
  end
end

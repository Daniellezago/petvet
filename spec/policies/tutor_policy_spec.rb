require "rails_helper"

RSpec.describe TutorPolicy, type: :policy do
  let(:admin)       { create(:user, :admin) }
  let(:veterinario) { create(:user, :veterinario) }
  let(:atendente)   { create(:user, :atendente) }
  let(:tutor)       { create(:tutor) }

  subject { described_class }

  describe "index?" do
    it "permite admin" do
      expect(subject.new(admin, tutor)).to permit_action(:index)
    end

    it "permite veterinário" do
      expect(subject.new(veterinario, tutor)).to permit_action(:index)
    end

    it "permite atendente" do
      expect(subject.new(atendente, tutor)).to permit_action(:index)
    end
  end

  describe "create?" do
    it "permite admin" do
      expect(subject.new(admin, tutor)).to permit_action(:create)
    end

    it "permite veterinário" do
      expect(subject.new(veterinario, tutor)).to permit_action(:create)
    end

    it "permite atendente" do
      expect(subject.new(atendente, tutor)).to permit_action(:create)
    end
  end

  describe "destroy? (inativar)" do
    it "permite admin" do
      expect(subject.new(admin, tutor)).to permit_action(:destroy)
    end

    it "bloqueia veterinário" do
      expect(subject.new(veterinario, tutor)).not_to permit_action(:destroy)
    end

    it "bloqueia atendente" do
      expect(subject.new(atendente, tutor)).not_to permit_action(:destroy)
    end
  end
end
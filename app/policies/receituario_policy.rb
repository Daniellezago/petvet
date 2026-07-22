class ReceituarioPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.crmv.present?
  end

  def update?
    true
  end

  # Receituário nunca pode ser removido — histórico médico é permanente.
  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

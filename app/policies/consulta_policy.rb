class ConsultaPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  # Consulta nunca pode ser removida — histórico médico é permanente.
  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end

class UserPolicy < ApplicationPolicy
  # Só admin pode ver lista de usuários
  def index?
    user.admin?
  end

  # Só admin pode ver detalhes de outro usuário
  def show?
    user.admin?
  end

  # Só admin pode criar usuários
  def create?
    user.admin?
  end

  # Só admin pode editar usuários
  def update?
    user.admin?
  end

  # Ninguém pode apagar usuário (soft delete apenas)
  def destroy?
    false
  end
end
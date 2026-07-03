class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  ROLES = %w[admin veterinario atendente].freeze

  before_save { self.email = email.downcase }

  validates :role, presence: true, inclusion: { in: ROLES }

  scope :ativos, -> { where(ativo: true) }

  def admin?
    role == "admin"
  end

  def veterinario?
    role == "veterinario"
  end

  def atendente?
    role == "atendente"
  end
end

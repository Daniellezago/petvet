class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  ROLES = %w[admin veterinario atendente].freeze

  PASSWORD_COMPLEXITY = /\A
    (?=.*[a-z])       # ao menos uma minúscula
    (?=.*[A-Z])       # ao menos uma maiúscula
    (?=.*\d)          # ao menos um número
    (?=.*[^A-Za-z0-9]) # ao menos um caractere especial
  /x

  before_save { self.email = email.downcase }
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :password, format: {
    with: PASSWORD_COMPLEXITY,
    message: "deve conter maiúscula, minúscula, número e caractere especial"
  }, if: -> { password.present? }

  scope :ativos, -> { where(ativo: true) }

  def admin? = role == "admin"
  def veterinario? = role == "veterinario"
  def atendente? = role == "atendente"
end
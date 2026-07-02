class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  ROLES = %w[admin veterinario atendente].freeze

  before_save { self.email_address = email_address.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
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

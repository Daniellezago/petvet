class User < ApplicationRecord
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable,
          :jwt_authenticatable,
          jwt_revocation_strategy: JwtDenylist

  # Regra de Senha Forte: exige pelo menos 1 minúscula, 1 maiúscula, 1 número e 1 caractere especial
  PASSWORD_REQUIREMENTS = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).+\z/

  validates :password, format: {
    with: PASSWORD_REQUIREMENTS,
    message: :invalid_password
  }, if: :password_required?

  enum :role, { admin: 0, veterinario: 1, atendente: 2 }, default: :atendente

  has_one :veterinario, dependent: :restrict_with_error

  has_many :consultas, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :vacinas, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :exames, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :receituarios, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :agendamentos, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :pesos, foreign_key: :usuario_id, dependent: :restrict_with_error

  before_save { self.email = email.downcase }

  validates :role, presence: true

  scope :ativos, -> { where(ativo: true) }

  private

  # Executa a validação apenas na criação ou se a senha for preenchida no formulário
  def password_required?
    new_record? || password.present?
  end
end

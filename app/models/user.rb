class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  enum :role, { admin: 0, veterinario: 1, atendente: 2 }, default: :atendente
  has_many :consultas, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :vacinas, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :exames, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :receituarios, foreign_key: :usuario_id, dependent: :restrict_with_error
  
  before_save { self.email = email.downcase }
  validates :role, presence: true

  scope :ativos, -> { where(ativo: true) }
end

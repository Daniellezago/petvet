class Tutor < ApplicationRecord
  has_many :pets, dependent: :restrict_with_error

  before_save { self.email = email.downcase if email.present? }

  validates :nome, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false, conditions: -> { where(ativo: true) } },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, presence: true,
                  uniqueness: { conditions: -> { where(ativo: true) } }
  validates :telefone, presence: true

  scope :ativos, -> { where(ativo: true) }
end
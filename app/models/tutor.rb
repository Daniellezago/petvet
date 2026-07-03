class Tutor < ApplicationRecord
  acts_as_paranoid

  # has_many :pets, dependent: :destroy
  # has_many :contratos, dependent: :destroy

  before_save { self.email = email.downcase if email.present? }

  validates :nome, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, presence: true, uniqueness: true
  validates :telefone, presence: true

  scope :ativos, -> { where(ativo: true) }
end

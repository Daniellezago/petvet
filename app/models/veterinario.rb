class Veterinario < ApplicationRecord
  belongs_to :user

  validates :nome, presence: true
  validates :crmv, presence: true, uniqueness: true
  validates :cor_agenda, presence: true
  validates :user_id, uniqueness: true

  scope :ativos, -> { where(ativo: true) }
end

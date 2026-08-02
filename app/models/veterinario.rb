class Veterinario < ApplicationRecord
  belongs_to :user

  validates :nome, presence: true
  validates :crmv, presence: true, uniqueness: true

  scope :ativos, -> { where(ativo: true) }
end

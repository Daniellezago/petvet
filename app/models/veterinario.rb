class Veterinario < ApplicationRecord
  belongs_to :user

  accepts_nested_attributes_for :user

  validates :nome, presence: true
  validates :crmv, presence: true, uniqueness: true
  validates :cor_agenda,  presence: true,
                          uniqueness: { case_sensitive: false, conditions: -> { where(ativo: true) } }
  validates :user_id, uniqueness: true, allow_nil: true

  scope :ativos, -> { where(ativo: true) }
end

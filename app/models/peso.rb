class Peso < ApplicationRecord
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  validates :data, presence: true
  validates :peso, presence: true, numericality: { greater_than: 0 }

  validate :data_nao_pode_ser_futura

  before_destroy :impedir_destroy

  private

  def impedir_destroy
    errors.add(:base, "Registros de peso não podem ser removidos: histórico médico é permanente")
    throw :abort
  end

  def data_nao_pode_ser_futura
    return if data.blank?

    errors.add(:data, "não pode ser uma data futura") if data > Date.current
  end
end

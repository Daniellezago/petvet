class Exame < ApplicationRecord
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  validates :tipo_exame, presence: true
  validates :data, presence: true

  validate :data_nao_pode_ser_futura

  # Exame é histórico médico permanente — mesmo padrão de proteção
  # já aplicado ao Pet, Consulta e Vacina.
  before_destroy :impedir_destroy

  private

  def impedir_destroy
    errors.add(:base, "Exames não podem ser removidos: histórico médico é permanente")
    throw :abort
  end

  def data_nao_pode_ser_futura
    return if data.blank?

    if data > Date.current
      errors.add(:data, "não pode ser uma data futura")
    end
  end
end
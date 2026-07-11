class Consulta < ApplicationRecord
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  validates :data, presence: true
  validates :descricao, presence: true

  validate :data_nao_pode_ser_futura

  # Consulta é histórico médico permanente — nunca pode ser removida,
  # pelo mesmo motivo do Pet: proteção legal da clínica e acesso do
  # tutor ao histórico completo do atendimento.
  before_destroy :impedir_destroy

  private

  def impedir_destroy
    errors.add(:base, "Consultas não podem ser removidas: histórico médico é permanente")
    throw :abort
  end

  def data_nao_pode_ser_futura
    return if data.blank?

    if data > Time.current
      errors.add(:data, "não pode ser uma data futura")
    end
  end
end

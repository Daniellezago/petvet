class Vacina < ApplicationRecord
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  enum :categoria, { vacina: 0, antiparasitario: 1 }, default: :vacina

  validates :nome, presence: true
  validates :data_aplicacao, presence: true

  validate :data_aplicacao_nao_pode_ser_futura
  validate :proxima_dose_deve_ser_depois_da_aplicacao

  # Vacina é histórico médico permanente — mesmo padrão de proteção do Pet e Consulta.
  before_destroy :impedir_destroy

  private

  def impedir_destroy
    errors.add(:base, "Vacinas não podem ser removidas: histórico médico é permanente")
    throw :abort
  end

  def data_aplicacao_nao_pode_ser_futura
    return if data_aplicacao.blank?

    if data_aplicacao > Date.current
      errors.add(:data_aplicacao, "não pode ser uma data futura")
    end
  end

  def proxima_dose_deve_ser_depois_da_aplicacao
    return if proxima_dose.blank? || data_aplicacao.blank?

    if proxima_dose <= data_aplicacao
      errors.add(:proxima_dose, "deve ser uma data posterior à data de aplicação")
    end
  end
end

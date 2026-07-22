class Contrato < ApplicationRecord
  belongs_to :tutor
  belongs_to :pet

  enum :tipo_contrato, { particular: 0, convenio: 1 }, default: :particular

  validates :data_inicio, presence: true

  validate :pet_deve_pertencer_ao_tutor
  validate :campos_de_convenio_obrigatorios_se_for_convenio
  validate :percentual_cobertura_dentro_do_intervalo_valido

  private

  def pet_deve_pertencer_ao_tutor
    return if pet.blank? || tutor.blank?

    if pet.tutor_id != tutor_id
      errors.add(:pet, "deve pertencer ao tutor informado")
    end
  end

  def campos_de_convenio_obrigatorios_se_for_convenio
    return unless convenio?

    errors.add(:nome_convenio, "é obrigatório para contratos de convênio") if nome_convenio.blank?
    errors.add(:numero_carteirinha, "é obrigatório para contratos de convênio") if numero_carteirinha.blank?
    errors.add(:percentual_cobertura, "é obrigatório para contratos de convênio") if percentual_cobertura.blank?
  end

  def percentual_cobertura_dentro_do_intervalo_valido
    return if percentual_cobertura.blank?

    unless percentual_cobertura.between?(0, 100)
      errors.add(:percentual_cobertura, "deve estar entre 0 e 100")
    end
  end
end

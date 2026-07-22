class Exame < ApplicationRecord
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  has_one_attached :arquivo

  CONTENT_TYPES_PERMITIDOS = %w[application/pdf image/jpeg image/png].freeze

  validates :tipo_exame, presence: true
  validates :data, presence: true

  validate :data_nao_pode_ser_futura
  validate :arquivo_deve_ter_tipo_permitido

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

  def arquivo_deve_ter_tipo_permitido
    return unless arquivo.attached?

    unless arquivo.content_type.in?(CONTENT_TYPES_PERMITIDOS)
      errors.add(:arquivo, "deve ser um arquivo PDF, JPEG ou PNG")
    end
  end
end

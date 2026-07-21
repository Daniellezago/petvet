class Receituario < ApplicationRecord
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  enum :tipo_receituario, { simples: 0, controle_especial: 1 }, default: :simples

  validates :medicamento, presence: true
  validates :posologia, presence: true
  validates :crmv_responsavel, presence: true
  validates :data_emissao, presence: true

  validate :data_emissao_nao_pode_ser_futura
  validate :usuario_deve_ter_crmv_cadastrado

  # Receituário é histórico médico permanente — mesmo padrão de proteção
  # já aplicado ao Pet, Consulta, Vacina e Exame.
  before_destroy :impedir_destroy

  private

  def impedir_destroy
    errors.add(:base, "Receituários não podem ser removidos: histórico médico é permanente")
    throw :abort
  end

  def data_emissao_nao_pode_ser_futura
    return if data_emissao.blank?

    if data_emissao > Date.current
      errors.add(:data_emissao, "não pode ser uma data futura")
    end
  end

  def usuario_deve_ter_crmv_cadastrado
    return if usuario.blank?

    if usuario.crmv.blank?
      errors.add(:usuario, "precisa ter um CRMV cadastrado para emitir receituário")
    end
  end
end

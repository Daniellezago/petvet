class Pet < ApplicationRecord
  belongs_to :tutor

  enum :sexo, { macho: 0, femea: 1 }

  validates :nome, presence: true
  validates :especie, presence: true
  validates :sexo, presence: true
  validates :peso_atual,
            numericality: { greater_than: 0 },
            allow_nil: true

  validate :data_nascimento_nao_pode_ser_futura

  has_many :consultas, dependent: :restrict_with_error
  has_many :vacinas, dependent: :restrict_with_error
  has_many :exames, dependent: :restrict_with_error
  has_many :receituarios, dependent: :restrict_with_error
  has_many :agendamentos, dependent: :restrict_with_error
  has_many :contratos, dependent: :restrict_with_error

  before_destroy :impedir_destroy

  private

  def impedir_destroy
    errors.add(:base, "Pets não podem ser removidos: histórico médico é permanente")
    throw :abort
  end

  def data_nascimento_nao_pode_ser_futura
    return if data_nascimento.blank?

    if data_nascimento > Date.current
      errors.add(:data_nascimento, "não pode ser uma data futura")
    end
  end
end

class Pet < ApplicationRecord
  belongs_to :tutor

  has_one_attached :foto

  enum :sexo, { macho: 0, femea: 1 }
  enum :porte, { pequeno: 0, medio: 1, grande: 2 }, default: :medio

  validates :nome, presence: true
  validates :especie, presence: true
  validates :sexo, presence: true
  validates :peso_atual,
            numericality: { greater_than: 0 },
            allow_nil: true

  validate :data_nascimento_nao_pode_ser_futura
  validate :foto_valida

  has_many :consultas, dependent: :restrict_with_error
  has_many :vacinas, dependent: :restrict_with_error
  has_many :exames, dependent: :restrict_with_error
  has_many :receituarios, dependent: :restrict_with_error
  has_many :agendamentos, dependent: :restrict_with_error
  has_many :contratos, dependent: :restrict_with_error
  has_many :pesos, dependent: :restrict_with_error

  before_destroy :impedir_destroy

  def idade
    return nil if data_nascimento.blank?

    hoje = Date.current
    anos = hoje.year - data_nascimento.year
    meses = hoje.month - data_nascimento.month

    if hoje.day < data_nascimento.day
      meses -= 1
    end

    if meses < 0
      anos -= 1
      meses += 12
    end

    if anos.positive?
      meses.positive? ? "#{anos} ano#{"s" if anos != 1}, #{meses} mes#{"es" if meses != 1}" : "#{anos} ano#{"s" if anos != 1}"
    else
      "#{meses} mes#{"es" if meses != 1}"
    end
  end

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

  def foto_valida
    return unless foto.attached?

    unless foto.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:foto, "deve ser um arquivo JPEG, PNG ou WEBP")
    end

    if foto.blob.byte_size > 5.megabytes
      errors.add(:foto, "deve ter no máximo 5MB")
    end
  end
end

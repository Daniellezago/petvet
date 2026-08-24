class User < ApplicationRecord
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable,
          :jwt_authenticatable,
          jwt_revocation_strategy: JwtDenylist

  # Regra de Senha Forte: exige pelo menos 1 minúscula, 1 maiúscula, 1 número e 1 caractere especial
  PASSWORD_REQUIREMENTS = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).+\z/

  validates :password, format: {
    with: PASSWORD_REQUIREMENTS,
    message: :invalid_password
  }, if: :password_required?

  enum :role, { admin: 0, veterinario: 1, atendente: 2 }, default: :atendente

  has_one :veterinario, dependent: :restrict_with_error

  has_many :consultas, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :vacinas, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :exames, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :receituarios, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :agendamentos, foreign_key: :usuario_id, dependent: :restrict_with_error
  has_many :pesos, foreign_key: :usuario_id, dependent: :restrict_with_error

  before_save { self.email = email.downcase }

  validates :role, presence: true

  # Criptografia nativa do Rails: o valor fica protegido no banco,
  # mesmo que alguém consiga acesso direto ao arquivo do banco de dados.
  encrypts :otp_secret

  # --- Autenticação de dois fatores (2FA) ---

  # Gera uma nova chave secreta TOTP para o usuário (usada ao ativar o 2FA)
  def generate_otp_secret!
    update!(otp_secret: ROTP::Base32.random)
  end

  # URL usada para gerar o QR code que o Google Authenticator/Microsoft Authenticator escaneia
  def otp_provisioning_uri
    ROTP::TOTP.new(otp_secret, issuer: "PetVet").provisioning_uri(email)
  end

  # Confere se o código de 6 dígitos digitado é válido neste momento
  # (drift_behind aceita um código "atrasado" de até ~30s, útil quando o
  # relógio do celular está levemente dessincronizado)
  def verify_otp(codigo)
    return false if otp_secret.blank?

    ROTP::TOTP.new(otp_secret).verify(codigo, drift_behind: 1)
  end

  # Gera 10 códigos de backup novos, guarda o hash de cada um (nunca o código em texto puro)
  # e devolve os códigos originais — que só podem ser mostrados nesse momento, uma única vez.
  def generate_backup_codes!
    codigos = Array.new(10) { SecureRandom.alphanumeric(10).upcase }
    hashes = codigos.map { |codigo| BCrypt::Password.create(codigo) }
    update!(otp_backup_codes: hashes.to_json)
    codigos
  end

  # Tenta "gastar" um código de backup. Se bater com algum hash guardado,
  # remove esse código da lista (uso único) e retorna true.
  def consume_backup_code!(codigo)
    return false if otp_backup_codes.blank?

    hashes = JSON.parse(otp_backup_codes)
    indice = hashes.index { |hash| BCrypt::Password.new(hash) == codigo }
    return false if indice.nil?

    hashes.delete_at(indice)
    update!(otp_backup_codes: hashes.to_json)
    true
  end

  scope :ativos, -> { where(ativo: true) }

  private

  # Executa a validação apenas na criação ou se a senha for preenchida no formulário
  def password_required?
    new_record? || password.present?
  end
end

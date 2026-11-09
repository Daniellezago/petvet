class DoisFatoresController < ApplicationController
  before_action :authenticate_user!

  def new
    if current_user.otp_required_for_login?
      redirect_to perfil_path, notice: "A autenticação de dois fatores já está ativa."
      return
    end

    # Só gera uma chave nova se ainda não existir uma - assim,se a pessoa
    # atualizar a página depois de escanear o QR code, o código continua valendo.
    current_user.generate_otp_secret! if current_user.otp_secret.blank?
  end

  def create
    if current_user.verify_otp(params[:codigo])
      current_user.update!(otp_required_for_login: true)
      codigos = current_user.generate_backup_codes!
      flash[:codigos_backup] = codigos
      redirect_to codigos_backup_dois_fatores_path
    else
      flash.now[:alert] = "Código inválido. Confira o horário do seu celular e tente novamente"
        render :new, status: :unprocessable_entity
    end
  end

  def codigos_backup
    @codigos = flash[:codigos_backup]

    if @codigos.blank?
      redirect_to perfil_path, alert: "Nenhum código disponível para exibir."
    end
  end

  def gerar_backup_codes
    unless current_user.otp_required_for_login?
      redirect_to perfil_path, alert: "Ative o 2 FA antes de gerar códigos de backup."
      return
    end

    codigos = current_user.generate_backup_codes!
    flash[:codigos_backup] = codigos
    redirect_to codigos_backup_dois_fatores_path
  end

  def destroy
    if current_user.valid_password?(params[:senha_atual])
      current_user.update!(otp_required_for_login: false, otp_secret: nil, otp_backup_codes: nil)
      redirect_to perfil_path, notice: "Autenticação de dois fatores desativada"
    else
      redirect_to perfil_path, alert: "Senha atual incorreta. A autenticação de dois fatores não foi desativada."
    end
  end
end

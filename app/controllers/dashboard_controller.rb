class DashboardController < ApplicationController
  PERIODOS = {
    "30_dias" => { meses: 1,  label: "Últimos 30 dias" },
    "6_meses" => { meses: 6,  label: "Últimos 6 meses" },
    "1_ano"   => { meses: 12, label: "Este ano" }
  }.freeze

  def index
    @periodo = PERIODOS.key?(params[:periodo]) ? params[:periodo] : "6_meses"
    meses = PERIODOS[@periodo][:meses]

    @tutores_por_mes = Tutor.group_by_month(:created_at, last: meses).count
    @pets_por_mes    = Pet.group_by_month(:created_at, last: meses).count
    @total_racas     = Pet.distinct.count(:raca)
    @pets_por_raca   = Pet.group(:especie, :raca).count
  end
end

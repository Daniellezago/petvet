class AddTipoAgendamentoToAgendamentos < ActiveRecord::Migration[8.0]
  def change
    add_column :agendamentos, :tipo_agendamento, :integer, null: false, default: 0
  end
end

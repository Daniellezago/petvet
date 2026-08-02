class AddVeterinarioToAgendamentos < ActiveRecord::Migration[8.0]
  def change
    add_reference :agendamentos, :veterinario, null: true, foreign_key: true
  end
end

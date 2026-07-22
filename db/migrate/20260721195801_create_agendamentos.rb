class CreateAgendamentos < ActiveRecord::Migration[8.0]
  def change
    create_table :agendamentos do |t|
      t.datetime :data_hora, null: false
      t.integer :status, null: false, default: 0
      t.text :observacoes
      t.references :tutor, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :agendamentos, :data_hora
  end
end

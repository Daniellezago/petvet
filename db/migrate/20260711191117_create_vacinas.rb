class CreateVacinas < ActiveRecord::Migration[8.0]
  def change
    create_table :vacinas do |t|
      t.string :nome, null: false
      t.date :data_aplicacao, null: false
      t.date :proxima_dose
      t.string :lote
      t.string :fabricante
      t.text :observacoes
      t.references :pet, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :vacinas, :data_aplicacao
  end
end

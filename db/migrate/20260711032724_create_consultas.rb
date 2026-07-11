class CreateConsultas < ActiveRecord::Migration[8.0]
  def change
    create_table :consultas do |t|
      t.datetime :data, null: false
      t.text :descricao, null: false
      t.text :diagnostico
      t.text :tratamento
      t.text :observacoes
      t.references :pet, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :consultas, :data
  end
end

class CreatePesos < ActiveRecord::Migration[8.0]
  def change
    create_table :pesos do |t|
      t.date :data, null: false
      t.decimal :peso, precision: 5, scale: 2, null: false
      t.text :observacoes
      t.references :pet, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

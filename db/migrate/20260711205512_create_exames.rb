class CreateExames < ActiveRecord::Migration[8.0]
  def change
    create_table :exames do |t|
      t.string :tipo_exame, null: false
      t.date :data, null: false
      t.text :resultado
      t.text :observacoes
      t.references :pet, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :exames, :data
  end
end
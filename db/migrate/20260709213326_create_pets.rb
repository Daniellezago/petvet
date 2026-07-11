# db/migrate/XXXXXXXXXXXXXX_create_pets.rb
class CreatePets < ActiveRecord::Migration[8.0]
  def change
    create_table :pets do |t|
      t.string :nome, null: false
      t.string :especie, null: false
      t.string :raca
      t.integer :sexo, null: false, default: 0
      t.date :data_nascimento
      t.decimal :peso_atual, precision: 5, scale: 2
      t.references :tutor, null: false, foreign_key: true

      t.timestamps
    end

    add_index :pets, :nome
  end
end

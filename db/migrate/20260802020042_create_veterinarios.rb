class CreateVeterinarios < ActiveRecord::Migration[8.0]
  def change
    create_table :veterinarios do |t|
      t.string :nome, null: false
      t.string :crmv, null: false
      t.string :especialidade
      t.string :cor_agenda, null: false, default: "#059669"
      t.boolean :ativo, null: false, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :veterinarios, :crmv, unique: true
  end
end

class CreateContratos < ActiveRecord::Migration[8.0]
  def change
    create_table :contratos do |t|
      t.integer :tipo_contrato, null: false, default: 0
      t.string :nome_convenio
      t.string :numero_carteirinha
      t.decimal :percentual_cobertura, precision: 5, scale: 2
      t.date :data_inicio, null: false
      t.date :data_fim
      t.references :tutor, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true

      t.timestamps
    end

    add_index :contratos, :numero_carteirinha
  end
end

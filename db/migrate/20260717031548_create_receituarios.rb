class CreateReceituarios < ActiveRecord::Migration[8.0]
  def change
    create_table :receituarios do |t|
      t.integer :tipo_receituario, null: false, default: 0
      t.string :medicamento, null: false
      t.text :posologia, null: false
      t.string :duracao_tratamento
      t.text :observacoes
      t.string :crmv_responsavel, null: false
      t.date :data_emissao, null: false
      t.references :pet, null: false, foreign_key: true
      t.references :usuario, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :receituarios, :data_emissao
  end
end
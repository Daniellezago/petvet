class CreateTutors < ActiveRecord::Migration[8.0]
  def change
    create_table :tutors do |t|
      t.string :nome
      t.string :email
      t.string :telefone
      t.string :cpf
      t.string :endereco
      t.boolean :ativo
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

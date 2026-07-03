class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, default: "atendente", null: false
    add_column :users, :ativo, :boolean, default: true, null: false
  end
end
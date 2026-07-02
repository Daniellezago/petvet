class AddRoleAndAtivoToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string
    add_column :users, :ativo, :boolean
  end
end

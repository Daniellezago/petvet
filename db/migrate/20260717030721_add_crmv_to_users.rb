class AddCrmvToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :crmv, :string
  end
end

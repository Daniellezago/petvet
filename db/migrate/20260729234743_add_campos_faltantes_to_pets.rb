class AddCamposFaltantesToPets < ActiveRecord::Migration[8.0]
  def change
    add_column :pets, :castrado, :boolean, null: false, default: false
    add_column :pets, :porte, :integer, null: false, default: 1
    add_column :pets, :cor, :string
  end
end

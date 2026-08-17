class AddUniqueIndexToVeterinariosUserId < ActiveRecord::Migration[8.0]
  def change
    remove_index :veterinarios, :user_id
    add_index :veterinarios, :user_id, unique: true
  end
end

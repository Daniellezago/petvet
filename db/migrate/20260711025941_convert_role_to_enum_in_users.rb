class ConvertRoleToEnumInUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :role_int, :integer, default: 2, null: false

    execute <<-SQL
      UPDATE users SET role_int = CASE role
        WHEN 'admin' THEN 0
        WHEN 'veterinario' THEN 1
        WHEN 'atendente' THEN 2
        ELSE 2
      END
    SQL

    remove_column :users, :role
    rename_column :users, :role_int, :role
  end

  def down
    add_column :users, :role_str, :string, default: "atendente", null: false

    execute <<-SQL
      UPDATE users SET role_str = CASE role
        WHEN 0 THEN 'admin'
        WHEN 1 THEN 'veterinario'
        WHEN 2 THEN 'atendente'
        ELSE 'atendente'
      END
    SQL

    remove_column :users, :role
    rename_column :users, :role_str, :role
  end
end
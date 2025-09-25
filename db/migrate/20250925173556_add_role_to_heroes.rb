class AddRoleToHeroes < ActiveRecord::Migration[8.0]
  def change
    add_column :heroes, :role, :string
  end
end

class AddUserToHeroes < ActiveRecord::Migration[8.0]
  def change
    add_reference :heroes, :user, null: false, foreign_key: true
  end
end

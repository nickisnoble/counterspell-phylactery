class CreateHeroes < ActiveRecord::Migration[8.0]
  def change
    create_table :heroes do |t|
      t.string :name, null: false
      t.string :pronouns

      t.string :ideal
      t.string :flaw

      t.timestamps
    end

    add_index :heroes, :name, unique: true
  end
end

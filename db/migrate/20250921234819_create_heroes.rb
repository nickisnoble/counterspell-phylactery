class CreateHeroes < ActiveRecord::Migration[8.0]
  def change
    create_table :heroes do |t|
      t.string :name
      t.string :pronouns
      t.string :category
      t.references :role, null: false, foreign_key: true
      t.references :ancestry, null: false, foreign_key: true

      t.timestamps
    end
  end
end

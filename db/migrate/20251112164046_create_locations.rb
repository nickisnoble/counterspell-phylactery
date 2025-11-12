class CreateLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.text :address
      t.string :slug

      t.timestamps
    end
    add_index :locations, :slug, unique: true
  end
end

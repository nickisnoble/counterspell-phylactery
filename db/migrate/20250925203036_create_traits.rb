class CreateTraits < ActiveRecord::Migration[8.0]
  def change
    create_table :traits do |t|
      t.string :type
      t.string :name
      t.string :slug

      t.text :description
      t.text :abilities

      t.timestamps
    end
    add_index :traits, :slug, unique: true
  end
end

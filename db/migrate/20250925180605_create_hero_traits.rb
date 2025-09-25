class CreateHeroTraits < ActiveRecord::Migration[8.0]
  def change
    create_table :hero_backgrounds do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description

      t.timestamps
    end

    create_table :hero_ancestries do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.text :abilities

      t.timestamps
    end

    create_table :hero_character_classes do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description

      t.timestamps
    end

    add_index :hero_backgrounds, :slug, unique: true
    add_index :hero_ancestries, :slug, unique: true
    add_index :hero_character_classes, :slug, unique: true
  end
end

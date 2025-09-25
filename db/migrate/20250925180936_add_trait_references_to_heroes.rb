class AddTraitReferencesToHeroes < ActiveRecord::Migration[8.0]
  def change
    add_reference :heroes, :ancestry, null: false, foreign_key: { to_table: :hero_ancestries }
    add_reference :heroes, :background, null: false, foreign_key: { to_table: :hero_backgrounds }
    add_reference :heroes, :character_class, null: false, foreign_key: { to_table: :hero_character_classes }
  end
end

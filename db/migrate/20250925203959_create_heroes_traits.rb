class CreateHeroesTraits < ActiveRecord::Migration[8.0]
  def change
    create_table :heroes_traits, id: false do |t|
      t.belongs_to :hero, null: false, foreign_key: true
      t.belongs_to :trait, null: false, foreign_key: true
    end
  end
end

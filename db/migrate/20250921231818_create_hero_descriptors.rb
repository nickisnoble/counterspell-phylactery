class CreateHeroDescriptors < ActiveRecord::Migration[8.0]
  def change
    create_table :hero_descriptors do |t|
      t.string :type
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end

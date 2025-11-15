class CreateSeats < ActiveRecord::Migration[8.0]
  def change
    create_table :seats do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :hero, null: true, foreign_key: true

      t.timestamps
    end
  end
end

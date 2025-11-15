class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :event, null: false, foreign_key: true
      t.references :gm, null: false, foreign_key: { to_table: :users }
      t.integer :seat_count, default: 5, null: false

      t.timestamps
    end
  end
end

class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.integer :status
      t.time :start_time
      t.time :end_time
      t.decimal :ticket_price, precision: 10, scale: 2, default: 0
      t.references :location, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
    add_index :events, :slug, unique: true
  end
end

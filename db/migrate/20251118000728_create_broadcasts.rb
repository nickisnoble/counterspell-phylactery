class CreateBroadcasts < ActiveRecord::Migration[8.0]
  def change
    create_table :broadcasts do |t|
      t.string :subject
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.boolean :draft, default: true
      t.references :event, null: true, foreign_key: true
      t.string :recipient_type, default: "all_subscribers"
      t.json :recipient_filters

      t.timestamps
    end

    add_index :broadcasts, :scheduled_at
    add_index :broadcasts, :sent_at
    add_index :broadcasts, :draft
    add_index :broadcasts, :recipient_type
  end
end

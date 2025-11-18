class CreateUnsubscribeEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :unsubscribe_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :reason

      t.timestamps
    end

    add_index :unsubscribe_events, :created_at
  end
end

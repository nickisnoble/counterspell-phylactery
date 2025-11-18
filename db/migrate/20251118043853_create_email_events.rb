class CreateEmailEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :email_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :broadcast, null: true, foreign_key: true
      t.string :event_type, null: false
      t.string :resend_email_id, null: false
      t.json :metadata

      t.timestamps
    end

    add_index :email_events, :event_type
    add_index :email_events, :resend_email_id
    add_index :email_events, [:user_id, :event_type]
    add_index :email_events, :created_at
  end
end

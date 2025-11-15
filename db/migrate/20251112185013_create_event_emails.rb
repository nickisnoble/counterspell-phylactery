class CreateEventEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :event_emails do |t|
      t.references :event, null: false, foreign_key: true
      t.string :subject
      t.datetime :send_at
      t.datetime :sent_at

      t.timestamps
    end
  end
end

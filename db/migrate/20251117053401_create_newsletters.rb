class CreateNewsletters < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletters do |t|
      t.string :subject
      t.datetime :scheduled_at
      t.datetime :sent_at
      t.boolean :draft, default: true

      t.timestamps
    end

    add_index :newsletters, :scheduled_at
    add_index :newsletters, :sent_at
    add_index :newsletters, :draft
  end
end

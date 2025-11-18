class AddNeverSendEmailToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :never_send_email, :boolean, default: false, null: false
    add_index :users, :never_send_email
  end
end

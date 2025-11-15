class AddCheckedInAtToSeats < ActiveRecord::Migration[8.0]
  def change
    add_column :seats, :checked_in_at, :datetime
    add_index :seats, :checked_in_at
  end
end

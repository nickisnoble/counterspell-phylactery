class ConvertBroadcastsToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Add polymorphic columns
    add_column :broadcasts, :broadcastable_type, :string
    add_column :broadcasts, :broadcastable_id, :integer

    # Migrate existing event_id data
    Broadcast.where.not(event_id: nil).find_each do |broadcast|
      broadcast.update_columns(
        broadcastable_type: 'Event',
        broadcastable_id: broadcast.event_id
      )
    end

    # Add indexes
    add_index :broadcasts, [:broadcastable_type, :broadcastable_id]

    # Remove old event_id column and its index
    remove_index :broadcasts, :event_id if index_exists?(:broadcasts, :event_id)
    remove_foreign_key :broadcasts, :events if foreign_key_exists?(:broadcasts, :events)
    remove_column :broadcasts, :event_id
  end

  def down
    # Re-add event_id column
    add_reference :broadcasts, :event, foreign_key: true

    # Migrate polymorphic data back to event_id
    Broadcast.where(broadcastable_type: 'Event').find_each do |broadcast|
      broadcast.update_columns(event_id: broadcast.broadcastable_id)
    end

    # Remove polymorphic columns
    remove_index :broadcasts, [:broadcastable_type, :broadcastable_id]
    remove_column :broadcasts, :broadcastable_type
    remove_column :broadcasts, :broadcastable_id
  end
end

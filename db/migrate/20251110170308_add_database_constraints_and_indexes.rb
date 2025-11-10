class AddDatabaseConstraintsAndIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add composite unique index on heroes_traits join table for better query performance
    # This prevents duplicate associations and optimizes lookups
    add_index :heroes_traits, [:hero_id, :trait_id], unique: true, if_not_exists: true

    # Add NOT NULL constraints to critical fields in traits table
    # This ensures data integrity at the database level
    change_column_null :traits, :type, false
    change_column_null :traits, :name, false
  end
end

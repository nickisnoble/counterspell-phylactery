class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Index for Event.publicly_visible scope: where(status: [:upcoming, :past])
    add_index :events, :status

    # Index for Event ordering: order(date: :asc/:desc)
    add_index :events, :date

    # Indexes for EventReminderJob queries
    add_index :event_emails, :sent_at
    add_index :event_emails, :send_at

    # Composite index for seat availability checks: seats.where(game_id: X).where.not(user_id: nil)
    # Note: game_id already has a single-column index from the foreign key
    # This composite index will speed up the common pattern of checking seats per game
    add_index :seats, [:game_id, :user_id]
  end
end

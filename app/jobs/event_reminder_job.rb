class EventReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find all event emails that should be sent
    pending_emails = EventEmail
      .where(sent_at: nil)
      .where("send_at <= ?", Time.current)
      .includes(event: [:location, games: [:seats]])

    pending_emails.find_each do |event_email|
      # Find all users with seats for this event
      user_ids = event_email.event.games.flat_map { |game| game.seats.where.not(user_id: nil).pluck(:user_id) }.uniq
      users = User.where(id: user_ids)

      # Send email to each user
      users.find_each do |user|
        EventMailer.reminder(user: user, event_email: event_email).deliver_later
      end

      # Mark as sent
      event_email.mark_as_sent!
    end
  end
end

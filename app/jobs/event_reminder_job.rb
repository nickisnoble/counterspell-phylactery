class EventReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find all event emails that should be sent
    pending_emails = EventEmail
      .where(sent_at: nil)
      .where("send_at <= ?", Time.current)

    pending_emails.find_each do |event_email|
      # TODO: Send actual email via mailer
      # EventReminderMailer.reminder(event_email).deliver_later

      # Mark as sent
      event_email.mark_as_sent!
    end
  end
end

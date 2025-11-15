# Preview all emails at http://localhost:3000/rails/mailers/event_mailer
class EventMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/event_mailer/reminder
  def reminder
    user = User.first || User.create!(email: "preview@example.com")
    event = Event.first || Event.create!(
      name: "Preview Event",
      date: 1.week.from_now,
      status: :upcoming,
      location: Location.first || Location.create!(name: "Preview Location", address: "123 Main St")
    )
    event_email = event.event_emails.first || event.event_emails.create!(
      subject: "Reminder: Event coming up!",
      send_at: 1.day.from_now
    )

    EventMailer.reminder(user: user, event_email: event_email)
  end
end

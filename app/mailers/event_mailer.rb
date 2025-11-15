class EventMailer < ApplicationMailer
  def reminder(user:, event_email:)
    @user = user
    @event_email = event_email
    @event = event_email.event
    @seat = user.seats.joins(:game).find_by(games: { event_id: @event.id })

    mail(
      to: user.email,
      subject: event_email.subject
    )
  end
end

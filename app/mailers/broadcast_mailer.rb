class BroadcastMailer < ApplicationMailer
  def broadcast(user:, broadcast:)
    @user = user
    @broadcast = broadcast
    @event = broadcast.event

    mail(
      to: user.email,
      subject: broadcast.subject
    )
  end
end

class BroadcastMailer < ApplicationMailer
  def broadcast(user:, broadcast:)
    @user = user
    @broadcast = broadcast
    @event = broadcast.event

    mail(
      to: user.email,
      subject: broadcast.subject,
      headers: email_headers(user, broadcast)
    )
  end

  private

  def email_headers(user, broadcast)
    headers = {
      'X-Entity-Ref-ID' => broadcast.id.to_s,
      'X-Broadcast-Type' => broadcast.transactional? ? 'transactional' : 'marketing'
    }

    # Add List-Unsubscribe headers for marketing emails (RFC 8058)
    if broadcast.marketing?
      unsubscribe_link = unsubscribe_url(token: user.unsubscribe_token)
      headers['List-Unsubscribe'] = "<#{unsubscribe_link}>"
      headers['List-Unsubscribe-Post'] = 'List-Unsubscribe=One-Click'
    end

    headers
  end
end

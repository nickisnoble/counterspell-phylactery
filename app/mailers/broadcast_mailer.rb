class BroadcastMailer < ApplicationMailer
  def broadcast(user:, broadcast:)
    @user = user
    @broadcast = broadcast
    @event = broadcast.event
    @seat = broadcast.seat

    set_email_headers(user, broadcast)

    mail(
      to: user.email,
      subject: broadcast.subject
    )
  end

  private

  def set_email_headers(user, broadcast)
    headers['X-Entity-Ref-ID'] = broadcast.id.to_s
    headers['X-Broadcast-Type'] = broadcast.transactional? ? 'transactional' : 'marketing'

    # Add Resend tags for better email tracking and categorization
    tags = []
    tags << { name: 'category', value: broadcast.transactional? ? 'transactional' : 'marketing' }
    tags << { name: 'broadcast_id', value: broadcast.id.to_s }
    tags << { name: 'recipient_type', value: broadcast.recipient_type }
    if broadcast.seat
      tags << { name: 'type', value: 'seat_confirmation' }
    elsif broadcast.event
      tags << { name: 'type', value: 'event_reminder' }
    end
    headers['X-Tags'] = tags.to_json

    # Add List-Unsubscribe headers for marketing emails (RFC 8058)
    if broadcast.marketing?
      unsubscribe_link = unsubscribe_url(token: user.unsubscribe_token)
      headers['List-Unsubscribe'] = "<#{unsubscribe_link}>"
      headers['List-Unsubscribe-Post'] = 'List-Unsubscribe=One-Click'
    end
  end

  # UTM parameters for Pirsch tracking
  def utm_medium
    @broadcast.transactional? ? 'transactional_email' : 'marketing_email'
  end

  def utm_campaign
    if @seat
      'seat_confirmation'
    elsif @event
      'event_reminder'
    else
      @broadcast.subject.parameterize
    end
  end
end

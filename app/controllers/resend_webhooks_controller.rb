class ResendWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authentication

  def create
    payload = params.permit!.to_h

    event_type = payload["type"]
    event_data = payload["data"] || {}

    # Extract recipient email addresses
    recipients = Array(event_data["to"])

    # Process each recipient
    recipients.each do |email|
      user = User.find_by(email: email)
      next unless user # Skip if user doesn't exist

      # Find associated broadcast from tags if available
      broadcast_id = event_data.dig("tags", "broadcast_id")
      broadcast = broadcast_id.present? ? Broadcast.find_by(id: broadcast_id) : nil

      # Create email event record
      EmailEvent.create(
        user: user,
        broadcast: broadcast,
        event_type: event_type,
        resend_email_id: event_data["email_id"],
        metadata: event_data
      )

      # Handle bounces and complaints by setting never_send_email flag
      if event_type == "email.bounced" || event_type == "email.complained"
        user.update(never_send_email: true)
      end
    end

    # Return 200 OK as required by Resend
    head :ok
  end
end

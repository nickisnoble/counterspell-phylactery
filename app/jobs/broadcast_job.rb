class BroadcastJob < ApplicationJob
  queue_as :default

  def perform
    # Find all broadcasts that should be sent
    pending_broadcasts = Broadcast.pending.includes(:event)

    pending_broadcasts.find_each do |broadcast|
      # Get recipients based on broadcast type and filters
      recipients = broadcast.recipients

      # Send email to each recipient
      recipients.find_each do |user|
        BroadcastMailer.broadcast(user: user, broadcast: broadcast).deliver_later
      end

      # Mark as sent
      broadcast.mark_as_sent!
    end
  end
end

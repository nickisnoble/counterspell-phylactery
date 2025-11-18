class MigrateEmailsToBroadcasts < ActiveRecord::Migration[8.0]
  def up
    # Migrate EventEmails to Broadcasts
    EventEmail.find_each do |event_email|
      broadcast = Broadcast.new(
        subject: event_email.subject,
        scheduled_at: event_email.send_at,
        sent_at: event_email.sent_at,
        draft: false, # EventEmails were never drafts
        event_id: event_email.event_id,
        recipient_type: "event_attendees",
        created_at: event_email.created_at,
        updated_at: event_email.updated_at
      )

      # Copy rich text body if it exists
      if event_email.body.present?
        broadcast.body = event_email.body.body
      end

      broadcast.save!(validate: false) # Skip validations for migration
    end

    # Migrate Newsletters to Broadcasts
    Newsletter.find_each do |newsletter|
      broadcast = Broadcast.new(
        subject: newsletter.subject,
        scheduled_at: newsletter.scheduled_at,
        sent_at: newsletter.sent_at,
        draft: newsletter.draft,
        event_id: nil,
        recipient_type: "all_subscribers",
        created_at: newsletter.created_at,
        updated_at: newsletter.updated_at
      )

      # Copy rich text body if it exists
      if newsletter.body.present?
        broadcast.body = newsletter.body.body
      end

      broadcast.save!(validate: false) # Skip validations for migration
    end
  end

  def down
    # Remove migrated broadcasts
    Broadcast.where(recipient_type: ["event_attendees", "all_subscribers"]).destroy_all
  end
end

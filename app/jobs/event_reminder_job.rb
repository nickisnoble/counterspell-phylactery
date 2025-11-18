# DEPRECATED: Use BroadcastJob instead
# This job is kept for backwards compatibility but delegates to BroadcastJob
class EventReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Delegate to BroadcastJob which handles all broadcasts including event reminders
    BroadcastJob.perform_now
  end
end

class NewsletterSyncJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on ButtondownService::RateLimitError, wait: 1.minute, attempts: 5

  def perform(user_id, subscribe)
    user = User.find_by(id: user_id)
    return unless user

    service = ButtondownService.new

    if subscribe
      service.subscribe(user.email)
      Rails.logger.info("Subscribed #{user.email} to newsletter")
    else
      service.unsubscribe(user.email)
      Rails.logger.info("Unsubscribed #{user.email} from newsletter")
    end
  rescue => e
    Rails.logger.error("Failed to sync newsletter for user #{user_id}: #{e.message}")
    raise
  end
end

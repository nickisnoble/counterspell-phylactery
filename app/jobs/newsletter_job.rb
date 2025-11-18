class NewsletterJob < ApplicationJob
  queue_as :default

  def perform
    # Find all newsletters that should be sent
    pending_newsletters = Newsletter
      .where(sent_at: nil)
      .where(draft: false)
      .where("scheduled_at <= ?", Time.current)

    pending_newsletters.find_each do |newsletter|
      # Find all users who want to receive newsletters
      users = User.where(newsletter: true)

      # Send email to each user
      users.find_each do |user|
        NewsletterMailer.newsletter(user: user, newsletter: newsletter).deliver_later
      end

      # Mark as sent
      newsletter.mark_as_sent!
    end
  end
end

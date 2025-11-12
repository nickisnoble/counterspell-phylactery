class Event < ApplicationRecord
  include FriendlyPathable

  belongs_to :location
  has_many :games, dependent: :destroy
  has_many :event_emails, dependent: :destroy
  has_rich_text :description

  validates :date, presence: true

  enum :status, %w[planning upcoming past cancelled].index_by(&:itself), validate: true

  after_create :create_default_reminder_emails

  private

  def create_default_reminder_emails
    # 1 week before event
    event_emails.create!(
      subject: "Reminder: #{name} is one week away!",
      send_at: date - 7.days
    )

    # 1 day before event
    event_emails.create!(
      subject: "Reminder: #{name} is tomorrow!",
      send_at: date - 1.day
    )
  end
end

class Event < ApplicationRecord
  include FriendlyPathable

  belongs_to :location
  has_many :games, dependent: :destroy
  has_many :event_emails, dependent: :destroy
  has_rich_text :description

  accepts_nested_attributes_for :games, allow_destroy: true, reject_if: :all_blank

  validates :date, presence: true
  validates :ticket_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  enum :status, %w[planning upcoming past cancelled], validate: true

  scope :publicly_visible, -> { where(status: [:upcoming, :past]) }
  scope :visible_to_gm, -> { all } # GMs see all events

  after_create :create_default_reminder_emails

  def visible_to?(user)
    return true if user&.admin? || user&.gm?
    upcoming? || past?
  end

  private

  def create_default_reminder_emails
    one_week_before = date - 7.days
    one_day_before = date - 1.day

    # Only create reminders for future dates
    if one_week_before > Time.current
      event_emails.create!(
        subject: "Reminder: #{name} is one week away!",
        send_at: one_week_before
      )
    end

    if one_day_before > Time.current
      event_emails.create!(
        subject: "Reminder: #{name} is tomorrow!",
        send_at: one_day_before
      )
    end
  end
end

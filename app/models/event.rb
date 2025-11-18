class Event < ApplicationRecord
  include FriendlyPathable

  belongs_to :location
  has_many :games, dependent: :destroy
  has_many :event_emails, dependent: :destroy # Legacy - use broadcasts instead
  has_many :broadcasts, as: :broadcastable, dependent: :destroy
  has_rich_text :description

  accepts_nested_attributes_for :games, allow_destroy: true, reject_if: :all_blank

  validates :date, presence: true
  validates :ticket_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  enum :status, %w[planning upcoming past cancelled], validate: true

  scope :publicly_visible, -> { where(status: [:upcoming, :past]) }
  scope :visible_to_gm, -> { where(status: [:planning, :upcoming, :past, :cancelled]) }

  after_create :create_default_reminder_broadcasts

  def visible_to?(user)
    return true if user&.admin? || user&.gm?
    return has_ticket_holder?(user) if cancelled?
    upcoming? || past?
  end

  def has_ticket_holder?(user)
    return false unless user
    games.joins(:seats).where(seats: { user_id: user.id }).exists?
  end

  private

  def create_default_reminder_broadcasts
    one_week_before = date - 7.days
    one_day_before = date - 1.day

    # Only create reminders for future dates
    if one_week_before > Time.current
      broadcasts.create!(
        subject: "Reminder: #{name} is one week away!",
        scheduled_at: one_week_before,
        recipient_type: "event_attendees",
        draft: false
      )
    end

    if one_day_before > Time.current
      broadcasts.create!(
        subject: "Reminder: #{name} is tomorrow!",
        scheduled_at: one_day_before,
        recipient_type: "event_attendees",
        draft: false
      )
    end
  end
end

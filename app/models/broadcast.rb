class Broadcast < ApplicationRecord
  attr_writer :event_id

  belongs_to :broadcastable, polymorphic: true, optional: true
  has_many :email_events, dependent: :destroy
  has_rich_text :body

  validates :subject, presence: true
  validates :scheduled_at, presence: true
  validates :recipient_type, presence: true, inclusion: { in: %w[all_subscribers event_attendees filtered single_recipient] }
  validate :scheduled_at_cannot_change_after_sent
  validate :sent_at_cannot_change_after_sent
  validate :broadcastable_required_for_event_attendees
  validate :broadcastable_required_for_single_recipient
  before_validation :assign_event_broadcastable

  scope :published, -> { where(draft: false) }
  scope :pending, -> { where(sent_at: nil, draft: false).where("scheduled_at <= ?", Time.current) }

  # Transactional emails are attached to a specific entity (Event, Seat, etc.)
  # Marketing emails are general broadcasts (newsletters, announcements)
  def transactional?
    broadcastable.present?
  end

  def marketing?
    !transactional?
  end

  def sent?
    sent_at.present?
  end

  def draft?
    draft
  end

  def mark_as_sent!
    update!(sent_at: Time.current)
  end

  # Convenience methods for accessing related objects
  def event
    case broadcastable_type
    when 'Event'
      broadcastable
    when 'Seat'
      broadcastable.game.event
    end
  end

  def seat
    broadcastable if broadcastable_type == 'Seat'
  end

  def event_id
    @event_id.presence || (broadcastable_type == "Event" ? broadcastable_id : nil)
  end

  # Returns the list of users who should receive this broadcast
  def recipients
    base_recipients = case recipient_type
    when "all_subscribers"
      User.where(newsletter: true)
    when "event_attendees"
      # Transactional emails go to all event attendees regardless of newsletter preference
      return User.none unless event
      user_ids = event.games.flat_map { |game| game.seats.where.not(user_id: nil).pluck(:user_id) }.uniq
      User.where(id: user_ids)
    when "filtered"
      apply_filters(User.where(newsletter: true))
    when "single_recipient"
      # For single recipient broadcasts (e.g. seat confirmations), send only to the associated user
      return User.none unless seat&.user
      User.where(id: seat.user.id)
    else
      User.none
    end

    # Always exclude users who have been flagged to never receive email
    # (bounced, complained, or manually blocked)
    base_recipients.where(never_send_email: false)
  end

  private

  def scheduled_at_cannot_change_after_sent
    return unless persisted? && sent? && scheduled_at_changed?

    errors.add(:scheduled_at, "cannot be changed after broadcast is sent")
  end

  def sent_at_cannot_change_after_sent
    return unless persisted? && sent_at_was.present? && sent_at_changed?

    errors.add(:sent_at, "cannot be changed after broadcast is sent")
  end

  def broadcastable_required_for_event_attendees
    return unless recipient_type == "event_attendees" && broadcastable.blank?

    errors.add(:broadcastable, "must exist for event_attendees")
  end

  def broadcastable_required_for_single_recipient
    return unless recipient_type == "single_recipient" && (broadcastable.blank? || seat.blank?)

    errors.add(:broadcastable, "must be a Seat for single_recipient")
  end

  def apply_filters(scope)
    return scope unless recipient_filters.present?

    scope = scope.where(system_role: recipient_filters["roles"]) if recipient_filters["roles"].present?

    scope = apply_attendance_filter(scope)

    if recipient_filters["name_search"].present?
      search = "%#{recipient_filters["name_search"]}%"
      scope = scope.where("display_name LIKE ? OR email LIKE ?", search, search)
    end

    scope
  end

  def assign_event_broadcastable
    return unless recipient_type == "event_attendees"

    self.broadcastable = Event.find_by(id: event_id)
  end

  def apply_attendance_filter(scope)
    attendance_filter = recipient_filters["attendance_filter"]
    attended_event_id = recipient_filters["attended_event_id"]

    return scope unless attendance_filter.present?

    case attendance_filter
    when "any"
      attendee_ids = Seat.where.not(user_id: nil).distinct.pluck(:user_id)
      scope.where(id: attendee_ids)
    when "never"
      attendee_ids = Seat.where.not(user_id: nil).distinct.pluck(:user_id)
      scope.where.not(id: attendee_ids)
    when "specific"
      if attended_event_id.present?
        event = Event.find_by(id: attended_event_id)
        if event
          user_ids = event.games.flat_map { |game| game.seats.where.not(user_id: nil).pluck(:user_id) }.uniq
          return scope.where(id: user_ids)
        end
      end
      scope.none
    else
      scope
    end
  end
end

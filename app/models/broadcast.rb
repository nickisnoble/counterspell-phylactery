class Broadcast < ApplicationRecord
  belongs_to :broadcastable, polymorphic: true, optional: true
  has_rich_text :body

  validates :subject, presence: true
  validates :scheduled_at, presence: true
  validates :recipient_type, presence: true, inclusion: { in: %w[all_subscribers event_attendees filtered] }
  validate :scheduled_at_cannot_change_after_sent
  validate :sent_at_cannot_change_after_sent
  validate :broadcastable_required_for_event_attendees

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

  # Convenience method for backward compatibility
  def event
    broadcastable if broadcastable_type == 'Event'
  end

  # Returns the list of users who should receive this broadcast
  def recipients
    case recipient_type
    when "all_subscribers"
      User.where(newsletter: true)
    when "event_attendees"
      # Transactional emails go to all event attendees regardless of newsletter preference
      return User.none unless event
      user_ids = event.games.flat_map { |game| game.seats.where.not(user_id: nil).pluck(:user_id) }.uniq
      User.where(id: user_ids)
    when "filtered"
      apply_filters(User.where(newsletter: true))
    else
      User.none
    end
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

  def apply_filters(scope)
    return scope unless recipient_filters.present?

    scope = scope.where(system_role: recipient_filters["roles"]) if recipient_filters["roles"].present?

    if recipient_filters["attended_event_id"].present?
      event = Event.find_by(id: recipient_filters["attended_event_id"])
      if event
        user_ids = event.games.flat_map { |game| game.seats.where.not(user_id: nil).pluck(:user_id) }.uniq
        scope = scope.where(id: user_ids)
      end
    end

    if recipient_filters["attended_any_event"] == true
      user_ids = Seat.where.not(user_id: nil).distinct.pluck(:user_id)
      scope = scope.where(id: user_ids)
    end

    if recipient_filters["never_attended"] == true
      user_ids = Seat.where.not(user_id: nil).distinct.pluck(:user_id)
      scope = scope.where.not(id: user_ids)
    end

    if recipient_filters["name_search"].present?
      search = "%#{recipient_filters["name_search"]}%"
      scope = scope.where("display_name LIKE ? OR email LIKE ?", search, search)
    end

    scope
  end
end

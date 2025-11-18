class Newsletter < ApplicationRecord
  has_rich_text :body

  validates :subject, presence: true
  validates :scheduled_at, presence: true
  validate :scheduled_at_cannot_change_after_sent
  validate :sent_at_cannot_change_after_sent

  scope :published, -> { where(draft: false) }

  def sent?
    sent_at.present?
  end

  def draft?
    draft
  end

  def mark_as_sent!
    update!(sent_at: Time.current)
  end

  private

  def scheduled_at_cannot_change_after_sent
    return unless persisted? && sent? && scheduled_at_changed?

    errors.add(:scheduled_at, "cannot be changed after newsletter is sent")
  end

  def sent_at_cannot_change_after_sent
    return unless persisted? && sent_at_was.present? && sent_at_changed?

    errors.add(:sent_at, "cannot be changed after newsletter is sent")
  end
end

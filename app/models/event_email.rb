class EventEmail < ApplicationRecord
  belongs_to :event
  has_rich_text :body

  validates :subject, presence: true
  validates :send_at, presence: true
  validate :send_at_cannot_change_after_sent
  validate :sent_at_cannot_change_after_sent

  def sent?
    sent_at.present?
  end

  def mark_as_sent!
    update!(sent_at: Time.current)
  end

  private

  def send_at_cannot_change_after_sent
    return unless persisted? && sent? && send_at_changed?

    errors.add(:send_at, "cannot be changed after email is sent")
  end

  def sent_at_cannot_change_after_sent
    return unless persisted? && sent_at_was.present? && sent_at_changed?

    errors.add(:sent_at, "cannot be changed after email is sent")
  end
end

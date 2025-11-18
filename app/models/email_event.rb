class EmailEvent < ApplicationRecord
  belongs_to :user
  belongs_to :broadcast, optional: true

  VALID_EVENT_TYPES = [
    "email.sent",
    "email.delivered",
    "email.delivery_delayed",
    "email.complained",
    "email.bounced",
    "email.opened",
    "email.clicked",
    "email.failed"
  ].freeze

  validates :event_type, presence: true, inclusion: { in: VALID_EVENT_TYPES }
  validates :resend_email_id, presence: true
end

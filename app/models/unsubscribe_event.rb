class UnsubscribeEvent < ApplicationRecord
  belongs_to :user

  REASONS = [
    "too_many_emails",
    "not_relevant",
    "never_subscribed",
    "privacy_concerns",
    "other"
  ].freeze

  validates :reason, inclusion: { in: REASONS }, allow_nil: true
end

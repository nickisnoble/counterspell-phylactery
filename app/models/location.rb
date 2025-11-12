class Location < ApplicationRecord
  include FriendlyPathable

  has_many :events, dependent: :restrict_with_error
  has_rich_text :about

  validates :address, presence: true
end

class Event < ApplicationRecord
  include FriendlyPathable

  belongs_to :location
  has_many :games, dependent: :destroy
  has_rich_text :description

  validates :date, presence: true

  enum :status, %w[planning upcoming past cancelled].index_by(&:itself), validate: true
end

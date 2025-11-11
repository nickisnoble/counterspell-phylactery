class Trait < ApplicationRecord
  self.inheritance_column = :_type_disabled # disable STI

  include FriendlyPathable

  has_and_belongs_to_many :heroes
  has_one_attached :cover

  validates :type, presence: :true, format: { with: /\A[a-zA-Z]+\z/ }
  normalizes :type, with: ->(t) { t.strip.upcase }

  normalizes :description, with: ->(t) { t.strip.squish }

  serialize :abilities, coder: JSON, type: Hash, default: {}
end

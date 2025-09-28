class Trait < ApplicationRecord
  self.inheritance_column = :_type_disabled # disable STI

  include FriendlyPathable

  has_and_belongs_to_many :heroes

  validates :type, presence: :true, format: /[a-zA-Z]+/
  normalizes :type, with: ->(t) { t.strip.upcase }

  # validates :description, length: { maximum: 200 }
  normalizes :description, with: ->(t) { t.strip.squish }

  serialize :abilities, coder: JSON, type: Hash, default: {}
end

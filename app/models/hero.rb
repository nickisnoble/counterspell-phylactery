class Hero < ApplicationRecord
  include FriendlyPathable

  has_rich_text :backstory
  has_one_attached :portrait

  belongs_to :ancestry
  belongs_to :background
  belongs_to :character_class

  normalizes :ideal, :flaw, with: ->(f) { f.strip }

  enum :role, %w[ fighter protector strategist wild_card ].index_by(&:itself), validate: true

  enum :pronouns, [ "He/Him", "She/Her", "They/Them" ].index_by(&:itself), validate: true, scopes: false, instance_methods: false
end

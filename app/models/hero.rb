class Hero < ApplicationRecord
  include FriendlyPathable

  belongs_to :user
  has_and_belongs_to_many :traits
  REQUIRED_TRAIT_TYPES = [ "ANCESTRY", "BACKGROUND", "CLASS" ].freeze
  validate :required_traits_present
  validate :no_duplicate_traits

  has_rich_text :summary
  has_rich_text :backstory
  has_one_attached :portrait

  normalizes :ideal, :flaw, with: ->(f) { f.strip }
  enum :role, %w[ fighter protector strategist wild_card ].index_by(&:itself), validate: true

  private

  def no_duplicate_traits
    traits.group_by(&:type).each do |type, group|
      if group.size > 1
        errors.add(:traits, "duplicate #{type.titleize} traits. Pick one!")
      end
    end
  end

  def required_traits_present
    present_types = traits.map(&:type)

    REQUIRED_TRAIT_TYPES.each do |type|
      unless present_types.include?(type)
        errors.add(:traits, "must include #{type.titleize}")
      end
    end
  end
end

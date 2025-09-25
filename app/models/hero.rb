class Hero < ApplicationRecord
  has_rich_text :backstory
  has_one_attached :portrait

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  normalizes :name, :ideal, :flaw, with: ->(f) { f.strip }

  # enum :category, %w[ fighter protector strategist wild_card ].index_by(&:itself), validate: true
  enum :pronouns, [ "He/Him", "She/Her", "They/Them" ].index_by(&:itself), validate: true, scopes: false, instance_methods: false

  def to_param
    name
  end
end

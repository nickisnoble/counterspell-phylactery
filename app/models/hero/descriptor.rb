class Hero::Descriptor < ApplicationRecord
  has_many :heroes
  validates :name, :description, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  normalizes :name, :description, with: ->(f) { f.strip }

  def to_param
    name
  end
end

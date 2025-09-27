class Term < ApplicationRecord
  include Sluggable

  normalizes :name, with: ->(f) { f.strip.squish }
  validates :title, presence: true, uniqueness: { case_sensitive: false }

  has_rich_text :body
  validates_presence_of :body

  private

  def set_slug
    self.slug ||= title.to_s.parameterize
  end
end

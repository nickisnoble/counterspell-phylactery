module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :set_slug, on: :create
    validates :slug, presence: true, uniqueness: { case_sensitive: false }
    def to_param = slug
  end

  private

  def set_slug
    return if slug.present?
    self.slug = self.class.generate_unique_slug
  end

  class_methods do
    def generate_unique_slug(length = 8)
      # Usually will run once but in case of collision,
      # will generate another
      loop do
        token = SecureRandom.base58(length)
        break token unless exists?(slug: token)
      end
    end

    def find_by_slug!(slug)
      find_by!(slug: slug)
    end
  end
end

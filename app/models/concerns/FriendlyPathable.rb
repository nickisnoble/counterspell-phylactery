module FriendlyPathable
  extend ActiveSupport::Concern

  included do
    include Sluggable

    normalizes :name, with: ->(f) { f.strip.squish }
    validates :name, presence: true, uniqueness: { case_sensitive: false }

    private

    def set_slug
      self.slug ||= name.to_s.parameterize
    end
  end
end

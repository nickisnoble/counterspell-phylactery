module Hero::Trait
  extend ActiveSupport::Concern

  included do
    include FriendlyPathable
    has_many :heroes

    validates :description, length: { maximum: 140 }
  end
end

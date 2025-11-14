class Game < ApplicationRecord
  belongs_to :event
  belongs_to :gm, class_name: "User"
  has_many :seats, dependent: :destroy

  validates :gm_id, presence: true
  validates :seat_count, numericality: { greater_than: 0 }
  validate :gm_must_have_appropriate_role

  private

  def gm_must_have_appropriate_role
    return unless gm

    unless gm.gm? || gm.admin?
      errors.add(:gm, "must have GM or Admin role")
    end
  end
end

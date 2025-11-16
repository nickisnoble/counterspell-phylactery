class Game < ApplicationRecord
  belongs_to :event
  belongs_to :gm, class_name: "User"
  has_many :seats, dependent: :destroy

  validates :gm_id, presence: true
  validates :seat_count, numericality: { greater_than: 0 }
  validate :gm_must_have_appropriate_role
  validate :one_association_per_event

  private

  def gm_must_have_appropriate_role
    return unless gm

    unless gm.gm? || gm.admin?
      errors.add(:gm, "must have GM or Admin role")
    end
  end

  def one_association_per_event
    return unless gm && event

    # Check if user is GMing another game at this event
    is_gm_at_another_game = Game.where(event: event, gm: gm).where.not(id: id).exists?

    # Check if user has a seat at any game in this event
    has_seat_at_event = Seat.joins(:game).where(
      user: gm,
      games: { event_id: event.id }
    ).exists?

    if is_gm_at_another_game || has_seat_at_event
      errors.add(:gm, "can only have one association per event")
    end
  end
end

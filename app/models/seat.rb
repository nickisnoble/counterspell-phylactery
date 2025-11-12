class Seat < ApplicationRecord
  belongs_to :game
  belongs_to :user, optional: true
  belongs_to :hero, optional: true

  validate :hero_unique_per_game, if: :hero_id?
  validate :one_seat_per_event, if: :user_id?

  before_create :set_purchased_at, if: :user_id?

  private

  def hero_unique_per_game
    return unless game

    if game.seats.where(hero_id: hero_id).where.not(id: id).exists?
      errors.add(:hero, "is already taken at this table")
    end
  end

  def one_seat_per_event
    return unless game && user

    event = game.event
    existing_seat = Seat.joins(:game).where(
      user: user,
      games: { event_id: event.id }
    ).where.not(id: id).exists?

    if existing_seat
      errors.add(:user, "can only have one seat per event")
    end
  end

  def set_purchased_at
    self.purchased_at ||= Time.current
  end
end

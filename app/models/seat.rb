class Seat < ApplicationRecord
  belongs_to :game
  belongs_to :user, optional: true
  belongs_to :hero, optional: true

  validate :hero_unique_per_game, if: :hero_id?

  private

  def hero_unique_per_game
    return unless game

    if game.seats.where(hero_id: hero_id).where.not(id: id).exists?
      errors.add(:hero, "is already taken at this table")
    end
  end
end

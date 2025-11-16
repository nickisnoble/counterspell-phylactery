# frozen_string_literal: true

module SeatBroadcasting
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_seat_changes, on: [:create, :update]
  end

  private

  def broadcast_seat_changes
    return unless game&.event && user_id
    return unless saved_change_to_checked_in_at? || saved_change_to_user_id? || saved_change_to_hero_id?

    # Broadcast to event show pages (full refresh)
    broadcast_refresh_to(game.event)

    # Broadcast targeted updates to wizard pages
    broadcast_wizard_updates
  end

  def broadcast_wizard_updates
    role_counts = game.seats.joins(:hero).where.not(hero_id: nil).group("heroes.role").count
    taken_hero_ids = game.seats.where.not(hero_id: nil).pluck(:hero_id)
    available_heroes = Hero.where.not(id: taken_hero_ids).order(:name).to_a

    broadcast_replace_later_to(
      game.event,
      target: "game_#{game.id}_role_selection",
      partial: "seats/role_selection",
      locals: { game: game, role_counts: role_counts }
    )

    broadcast_replace_later_to(
      game.event,
      target: "game_#{game.id}_hero_selection",
      partial: "seats/hero_selection",
      locals: { game: game, available_heroes: available_heroes }
    )
  end
end

# frozen_string_literal: true

module SeatBroadcasting
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_seat_changes, on: [:create, :update]
  end

  private

  def broadcast_seat_changes
    return unless game&.event && user_id
    return unless saved_change_to_checked_in_at? || saved_change_to_user_id? || saved_change_to_hero_id? || saved_change_to_game_id?

    # Broadcast to event show pages (full refresh)
    broadcast_refresh_to(game.event)

    # Broadcast targeted updates to wizard pages (current and previous game, if seat moved)
    games_to_broadcast = [game]

    if saved_change_to_game_id?
      old_game_id, = previous_changes["game_id"]
      old_game = Game.find_by(id: old_game_id)
      games_to_broadcast << old_game if old_game
    end

    games_to_broadcast.compact.uniq.each { |game_ctx| broadcast_wizard_updates_for(game_ctx) }
  end

  def broadcast_wizard_updates
    broadcast_wizard_updates_for(game)
  end

  def broadcast_wizard_updates_for(game_ctx)
    role_counts = game_ctx.seats.joins(:hero).where.not(hero_id: nil).group("heroes.role").count
    taken_hero_ids = game_ctx.seats.where.not(hero_id: nil).pluck(:hero_id)
    available_heroes = Hero.where.not(id: taken_hero_ids).order(:name).to_a

    broadcast_replace_to(
      game_ctx.event,
      target: "game_#{game_ctx.id}_role_selection",
      renderable: Views::Seats::RoleSelection.new(game: game_ctx, role_counts: role_counts)
    )

    broadcast_replace_to(
      game_ctx.event,
      target: "game_#{game_ctx.id}_hero_selection",
      renderable: Views::Seats::HeroSelection.new(game: game_ctx, available_heroes: available_heroes)
    )
  end
end

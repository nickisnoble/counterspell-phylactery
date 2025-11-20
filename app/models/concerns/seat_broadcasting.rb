# frozen_string_literal: true

module SeatBroadcasting
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_seat_changes, on: [:create, :update]
  end

  private

  def broadcast_seat_changes
    return unless game&.event && user_id

    relevant_changes = saved_changes.slice("checked_in_at", "user_id", "hero_id", "game_id")
    return if relevant_changes.empty?

    games_to_broadcast = [game]

    if relevant_changes["game_id"]
      old_game_id, = relevant_changes["game_id"]
      games_to_broadcast << Game.find_by(id: old_game_id)
    end

    games_to_broadcast.compact.uniq.each do |game_context|
      broadcast_refresh_to(game_context.event)
      broadcast_wizard_updates_for(game_context)
    end
  end

  def broadcast_wizard_updates
    broadcast_wizard_updates_for(game)
  end

  def broadcast_wizard_updates_for(game_context)
    role_counts = role_counts_for(game_context)
    available_heroes = available_heroes_for(game_context)

    broadcast_replace_to(
      game_context.event,
      target: "game_#{game_context.id}_role_selection",
      renderable: Views::Seats::RoleSelection.new(game: game_context, role_counts: role_counts)
    )

    broadcast_replace_to(
      game_context.event,
      target: "game_#{game_context.id}_hero_selection",
      renderable: Views::Seats::HeroSelection.new(game: game_context, available_heroes: available_heroes)
    )
  end

  def role_counts_for(game_context)
    game_context.seats.joins(:hero).where.not(hero_id: nil).group("heroes.role").count
  end

  def available_heroes_for(game_context)
    taken_hero_ids = game_context.seats.where.not(hero_id: nil).pluck(:hero_id)
    Hero.where.not(id: taken_hero_ids).order(:name).to_a
  end
end

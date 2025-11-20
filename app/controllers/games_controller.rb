class GamesController < ApplicationController
  before_action :require_gm_or_admin!
  before_action :set_game

  def show
    @event = @game.event
    @available_seats = @game.seat_count - @game.seats.where.not(user_id: nil).count
    @seats = @game.seats.includes(:user, :hero).where.not(user_id: nil)
    @is_today = @event.date == Date.today

    render Views::Games::Show.new(
      game: @game,
      event: @event,
      available_seats: @available_seats,
      seats: @seats,
      current_user: Current.user,
      is_today: @is_today,
      is_gm_or_admin: true
    )
  end

  private

  def set_game
    @game = Game.includes(:event, :gm, seats: [:user, :hero]).find(params[:id])
  end
end

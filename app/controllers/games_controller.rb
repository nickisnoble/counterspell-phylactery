class GamesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_game

  def show
    @event = @game.event
    unless @event.visible_to?(authenticated? ? Current.user : nil)
      redirect_to events_path, alert: "This event is not yet available for viewing"
      return
    end

    @available_seats = @game.seat_count - @game.seats.where.not(user_id: nil).count
    @seats = @game.seats.includes(:user, :hero).where.not(user_id: nil)

    render Views::Games::Show.new(
      game: @game,
      event: @event,
      available_seats: @available_seats,
      seats: @seats,
      current_user: authenticated? ? Current.user : nil
    )
  end

  private

  def set_game
    @game = Game.includes(:event, :gm, seats: [:user, :hero]).find(params[:id])
  end
end

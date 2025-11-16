class GamesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_game
  before_action :require_authentication_for_standalone, unless: :from_event_route?
  before_action :authorize_gm_or_admin_view, unless: :from_event_route?

  def show
    @event = @game.event

    # For public event route, use original logic
    if from_event_route?
      unless @event.visible_to?(authenticated? ? Current.user : nil)
        redirect_to events_path, alert: "This event is not yet available for viewing"
        return
      end
    end

    @available_seats = @game.seat_count - @game.seats.where.not(user_id: nil).count
    @seats = @game.seats.includes(:user, :hero).where.not(user_id: nil)
    @is_today = @event.date == Date.today

    render Views::Games::Show.new(
      game: @game,
      event: @event,
      available_seats: @available_seats,
      seats: @seats,
      current_user: authenticated? ? Current.user : nil,
      is_today: @is_today,
      is_gm_or_admin: from_event_route? ? false : true
    )
  end

  private

  def set_game
    @game = Game.includes(:event, :gm, seats: [:user, :hero]).find(params[:id])
  end

  def from_event_route?
    params[:event_id].present?
  end

  def require_authentication_for_standalone
    unless authenticated?
      redirect_to new_session_path, alert: "Please sign in"
    end
  end

  def authorize_gm_or_admin_view
    unless Current.user&.gm? || Current.user&.admin?
      redirect_to events_path, alert: "Access denied"
    end
  end
end

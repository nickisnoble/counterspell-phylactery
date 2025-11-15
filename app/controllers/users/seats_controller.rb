module Users
  class SeatsController < ApplicationController
    before_action :set_user

    def index
      @seats = @user.seats.includes(:game, :event, :hero).order(created_at: :desc)
      @upcoming_seats = @seats.joins(game: :event).where(events: { status: :upcoming }).order("events.date ASC")
      @past_seats = @seats.joins(game: :event).where(events: { status: :past }).order("events.date DESC")

      render Views::Users::Seats::Index.new(
        user: @user,
        upcoming_seats: @upcoming_seats,
        past_seats: @past_seats
      )
    end

    def show
      @seat = @user.seats.includes(game: :event).find(params[:id])
      @game = @seat.game
      @event = @game.event

      render Views::Seats::Show.new(seat: @seat, game: @game, event: @event)
    end

    private

    def set_user
      @user = User.find_by_slug!(params[:user_id])
      unless @user == Current.user || Current.user&.admin?
        redirect_to root_path, alert: "You can only view your own tickets"
      end
    end
  end
end

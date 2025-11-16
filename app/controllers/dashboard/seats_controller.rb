class Dashboard::SeatsController < ApplicationController
  before_action :require_admin!
  before_action :set_event
  before_action :set_seat

  def update
    @seat.assign_attributes(seat_params)

    if @seat.save
      # Re-render the seat card on success
      render turbo_stream: turbo_stream.replace(
        "seat_#{@seat.id}",
        Views::Dashboard::Seats::SeatCard.new(seat: @seat, event: @event)
      )
    else
      # Re-render the seat card with errors
      render turbo_stream: turbo_stream.replace(
        "seat_#{@seat.id}",
        Views::Dashboard::Seats::SeatCardWithErrors.new(seat: @seat, event: @event)
      ), status: :unprocessable_content
    end
  end

  private

  def set_event
    @event = Event.find_by_slug!(params[:event_id])
  end

  def set_seat
    @seat = @event.seats.find(params[:id])
  end

  def seat_params
    params.require(:seat).permit(:game_id)
  end
end

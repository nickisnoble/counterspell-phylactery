class CheckInsController < ApplicationController
  before_action :require_gm_or_admin!

  def show
    # QR code scanner page
    render Views::CheckIns::Show.new
  end

  def create
    # Find seat by token
    seat = find_seat_by_token(params[:token])

    unless seat
      redirect_to check_in_path, alert: "Invalid QR code"
      return
    end

    if seat.checked_in?
      redirect_to check_in_path, notice: "#{seat.user.display_name} is already checked in"
      return
    end

    seat.check_in!
    redirect_to check_in_path, notice: "✓ #{seat.user.display_name} checked in successfully!"
  end

  def update
    # Manual check-in toggle from event page
    seat = Seat.find(params[:id])

    unless can_check_in?(seat)
      redirect_to event_path(seat.game.event), alert: "You don't have permission to check in users for this event"
      return
    end

    if seat.checked_in?
      seat.update!(checked_in_at: nil)
      redirect_to event_path(seat.game.event), notice: "#{seat.user.display_name} checked out"
    else
      seat.check_in!
      redirect_to event_path(seat.game.event), notice: "#{seat.user.display_name} checked in"
    end
  end

  private

  def find_seat_by_token(token)
    return nil unless token

    # Find seat where the token matches
    Seat.all.find { |seat| seat.qr_token == token }
  end

  def can_check_in?(seat)
    return true if Current.user.admin?

    # GMs can only check in for their own games
    seat.game.gm_id == Current.user.id
  end
end

class CheckinsController < ApplicationController
  before_action :require_gm_or_admin!

  def show
    # QR code scanner page with today's attendees
    todays_events = Event.where(date: Date.today)
    attendees = todays_events.flat_map { |event|
      event.games.flat_map { |game|
        game.seats.where.not(user_id: nil).includes(:user, :hero, game: [:gm, :event])
      }
    }

    render Views::Checkins::Show.new(attendees: attendees, events: todays_events)
  end

  def create
    # Find seat by token
    seat = find_seat_by_token(params[:token])

    unless seat
      redirect_to checkin_path, alert: "Invalid QR code"
      return
    end

    if seat.checked_in?
      redirect_to checkin_path, notice: "#{seat.user.display_name} is already checked in"
      return
    end

    seat.check_in!
    redirect_to checkin_path, notice: "✓ #{seat.user.display_name} checked in successfully!"
  end

  def update
    # Manual check-in toggle
    seat = Seat.find(params[:id])

    unless can_check_in?(seat)
      if request.headers["Turbo-Frame"]
        head :forbidden
      else
        redirect_to checkin_path, alert: "You don't have permission to check in users for this event"
      end
      return
    end

    # Toggle checkin status
    if seat.checked_in?
      seat.update!(checked_in_at: nil)
      notice_msg = "#{seat.user.display_name} checked out"
    else
      seat.check_in!
      notice_msg = "#{seat.user.display_name} checked in"
    end

    # Respond with Turbo Stream for in-place updates, or redirect for non-Turbo requests
    respond_to do |format|
      format.turbo_stream do
        # Determine which variant to use based on referer or default to compact
        variant = determine_variant(request.referer)

        render turbo_stream: turbo_stream.replace(
          "checkin_seat_#{seat.id}",
          Views::Components::CheckinButton.new(seat: seat.reload, variant: variant)
        )
      end
      format.html { redirect_to checkin_path, notice: notice_msg }
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

  def determine_variant(referer)
    return :compact unless referer

    # Use card variant for game show pages, compact for checkin page
    referer.include?("/events/") && referer.include?("/games/") ? :card : :compact
  end
end

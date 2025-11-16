class EventsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_event, only: [:show]

  def index
    @events = if authenticated? && (Current.user.gm? || Current.user.admin?)
      Event.includes(:location, games: :seats).visible_to_gm.order(:date)
    else
      Event.includes(:location, games: :seats).publicly_visible.order(:date)
    end

    # Sort by status priority (upcoming first, then planning, then past, then cancelled)
    @events = @events.to_a.sort_by { |event| [status_priority(event), event.date] }

    render Views::Events::Index.new(events: @events)
  end

  def show
    current_user = authenticated? ? Current.user : nil
    unless @event.visible_to?(current_user)
      redirect_to events_path, alert: "This event is not yet available for viewing"
      return
    end

    available_heroes = Hero.all
    render Views::Events::Show.new(event: @event, current_user: current_user, available_heroes: available_heroes)
  end

  private

  def status_priority(event)
    case event.status
    when "upcoming" then 0
    when "planning" then 1
    when "past" then 2
    when "cancelled" then 3
    else 4
    end
  end

  def set_event
    @event = Event.includes(:location, games: [:gm, :seats]).find_by_slug!(params[:id])
  end
end

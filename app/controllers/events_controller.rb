class EventsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_event, only: [:show]

  def index
    @events = if authenticated? && (Current.user.gm? || Current.user.admin?)
      Event.includes(:location).visible_to_gm.order(date: :asc)
    else
      Event.includes(:location).publicly_visible.order(date: :asc)
    end

    render Views::Events::Index.new(events: @events)
  end

  def show
    current_user = authenticated? ? Current.user : nil
    unless @event.visible_to?(current_user)
      redirect_to events_path, alert: "This event is not yet available for viewing"
      return
    end

    user_heroes = Hero.all
    render Views::Events::Show.new(event: @event, current_user: current_user, user_heroes: user_heroes)
  end

  private

  def set_event
    @event = Event.includes(:location, games: [:gm, :seats]).find_by_slug!(params[:id])
  end
end

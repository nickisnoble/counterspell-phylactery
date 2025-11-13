class EventsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_event, only: [:show]

  def index
    @events = if authenticated? && (Current.user.gm? || Current.user.admin?)
      Event.visible_to_gm.order(date: :asc)
    else
      Event.publicly_visible.order(date: :asc)
    end

    render Views::Events::Index.new(events: @events)
  end

  def show
    current_user = authenticated? ? Current.user : nil
    unless @event.visible_to?(current_user)
      redirect_to events_path, alert: "This event is not yet available for viewing"
      return
    end

    render Views::Events::Show.new(event: @event)
  end

  private

  def set_event
    @event = Event.find_by_slug!(params[:id])
  end
end

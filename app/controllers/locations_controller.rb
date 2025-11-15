class LocationsController < ApplicationController
  allow_unauthenticated_access

  def index
    @locations = Location.all.order(:name)
    render Views::Locations::Index.new(locations: @locations)
  end

  def show
    @location = Location.includes(events: :games).find_by_slug!(params[:id])
    @upcoming_events = @location.events.where(status: :upcoming).order(date: :asc)
    @past_events = @location.events.where(status: :past).order(date: :desc).limit(5)
    render Views::Locations::Show.new(
      location: @location,
      upcoming_events: @upcoming_events,
      past_events: @past_events
    )
  end
end

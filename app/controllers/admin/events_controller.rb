class Admin::EventsController < ApplicationController
  before_action :require_admin!
  before_action :set_event, only: [:edit, :update, :destroy]

  def index
    @events = Event.all.order(date: :desc)
    render Views::Admin::Events::Index.new(events: @events)
  end

  def new
    @event = Event.new
    render Views::Admin::Events::New.new(event: @event, locations: Location.all)
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path, notice: "Event created successfully"
    else
      render Views::Admin::Events::New.new(event: @event, locations: Location.all), status: :unprocessable_content
    end
  end

  def edit
    render Views::Admin::Events::Edit.new(event: @event, locations: Location.all)
  end

  def update
    if @event.update(event_params)
      redirect_to admin_events_path, notice: "Event updated successfully"
    else
      render Views::Admin::Events::Edit.new(event: @event, locations: Location.all), status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    redirect_to admin_events_path, notice: "Event deleted successfully"
  end

  private

  def set_event
    @event = Event.find_by_slug!(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :name, :date, :location_id, :status, :ticket_price,
      :start_time, :end_time, :description
    )
  end
end

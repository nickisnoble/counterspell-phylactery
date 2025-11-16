class Dashboard::EventsController < ApplicationController
  before_action :require_gm_or_admin!
  before_action :require_admin!, except: %i[ index ]
  before_action :set_event, only: [:edit, :update, :destroy]

  def index
    @events = Event.all.order(date: :desc)
    render Views::Dashboard::Events::Index.new(events: @events)
  end

  def new
    @event = Event.new
    3.times { @event.games.build(seat_count: 5) } # Default 3 games with 5 seats each
    render Views::Dashboard::Events::New.new(event: @event, locations: Location.all, gms: gm_users)
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to dashboard_events_path, notice: "Event created successfully"
    else
      render Views::Dashboard::Events::New.new(event: @event, locations: Location.all, gms: gm_users), status: :unprocessable_content
    end
  end

  def edit
    render Views::Dashboard::Events::Edit.new(event: @event, locations: Location.all, gms: gm_users)
  end

  def update
    if @event.update(event_params)
      redirect_to dashboard_events_path, notice: "Event updated successfully"
    else
      render Views::Dashboard::Events::Edit.new(event: @event, locations: Location.all, gms: gm_users), status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    redirect_to dashboard_events_path, notice: "Event deleted successfully"
  end

  private

  def set_event
    @event = Event.find_by_slug!(params[:id])
  end

  def gm_users
    User.where(system_role: [:gm, :admin]).order(:display_name)
  end

  def event_params
    params.require(:event).permit(
      :name, :date, :location_id, :status, :ticket_price,
      :start_time, :end_time, :description,
      games_attributes: [:id, :gm_id, :seat_count, :_destroy],
      seats_attributes: [:id, :game_id]
    )
  end
end

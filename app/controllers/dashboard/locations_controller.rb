class Dashboard::LocationsController < ApplicationController
  before_action :require_admin!
  before_action :set_location, only: [:edit, :update, :destroy]

  def index
    @locations = Location.all.order(created_at: :desc)
    render Views::Dashboard::Locations::Index.new(locations: @locations)
  end

  def new
    @location = Location.new
    render Views::Dashboard::Locations::New.new(location: @location)
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      # If coming from inline form (has referrer that's not dashboard locations)
      if request.referrer && !request.referrer.include?("dashboard/locations")
        redirect_to request.referrer, notice: "Location '#{@location.name}' created. Please select it from the dropdown."
      else
        redirect_to dashboard_locations_path, notice: "Location created successfully"
      end
    else
      render Views::Dashboard::Locations::New.new(location: @location), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Dashboard::Locations::Edit.new(location: @location)
  end

  def update
    if @location.update(location_params)
      redirect_to dashboard_locations_path, notice: "Location updated successfully"
    else
      render Views::Dashboard::Locations::Edit.new(location: @location), status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to dashboard_locations_path, notice: "Location deleted successfully"
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to dashboard_locations_path, alert: "Cannot delete location with existing events"
  end

  private

  def set_location
    @location = Location.find_by_slug!(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :about)
  end
end

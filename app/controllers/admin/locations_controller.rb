class Admin::LocationsController < ApplicationController
  before_action :require_admin!
  before_action :set_location, only: [:edit, :update, :destroy]

  def index
    @locations = Location.all.order(created_at: :desc)
    render Views::Admin::Locations::Index.new(locations: @locations)
  end

  def new
    @location = Location.new
    render Views::Admin::Locations::New.new(location: @location)
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      redirect_to admin_locations_path, notice: "Location created successfully"
    else
      render Views::Admin::Locations::New.new(location: @location), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Admin::Locations::Edit.new(location: @location)
  end

  def update
    if @location.update(location_params)
      redirect_to admin_locations_path, notice: "Location updated successfully"
    else
      render Views::Admin::Locations::Edit.new(location: @location), status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to admin_locations_path, notice: "Location deleted successfully"
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_locations_path, alert: "Cannot delete location with existing events"
  end

  private

  def set_location
    @location = Location.find_by_slug!(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :about)
  end
end

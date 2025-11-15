class DashboardsController < ApplicationController
  before_action :require_admin!

  def show
    render Views::Dashboards::Show.new
  end
end

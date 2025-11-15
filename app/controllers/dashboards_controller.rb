class DashboardsController < ApplicationController
  before_action :require_gm_or_admin!

  def show
    render Views::Dashboards::Show.new
  end
end

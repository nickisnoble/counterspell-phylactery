class DashboardsController < ApplicationController
  before_action :require_admin!

  def show
    render Dashboards::Show.new(current_user: Current.user)
  end
end

class EventsController < ApplicationController
  def index
    render Views::Events::Index.new
  end
end

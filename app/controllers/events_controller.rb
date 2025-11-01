class EventsController < ApplicationController
  def index
    render Events::Index.new
  end
end

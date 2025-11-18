class BroadcastsController < ApplicationController
  allow_unauthenticated_access

  def show
    @broadcast = Broadcast.published.find(params[:id])
    render Views::Broadcasts::Show.new(broadcast: @broadcast)
  end
end

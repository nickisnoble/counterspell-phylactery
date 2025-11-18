class Dashboard::BroadcastsController < ApplicationController
  before_action :require_admin!
  before_action :set_broadcast, only: [:edit, :update, :destroy]

  def index
    @broadcasts = Broadcast.all.order(scheduled_at: :desc)
    render Views::Dashboard::Broadcasts::Index.new(broadcasts: @broadcasts)
  end

  def new
    @broadcast = Broadcast.new
    render Views::Dashboard::Broadcasts::New.new(broadcast: @broadcast, events: Event.all.order(date: :desc))
  end

  def create
    @broadcast = Broadcast.new(broadcast_params)
    if @broadcast.save
      redirect_to dashboard_broadcasts_path, notice: "Broadcast created successfully"
    else
      render Views::Dashboard::Broadcasts::New.new(broadcast: @broadcast, events: Event.all.order(date: :desc)), status: :unprocessable_content
    end
  end

  def edit
    render Views::Dashboard::Broadcasts::Edit.new(broadcast: @broadcast, events: Event.all.order(date: :desc))
  end

  def update
    if @broadcast.update(broadcast_params)
      redirect_to dashboard_broadcasts_path, notice: "Broadcast updated successfully"
    else
      render Views::Dashboard::Broadcasts::Edit.new(broadcast: @broadcast, events: Event.all.order(date: :desc)), status: :unprocessable_content
    end
  end

  def destroy
    if @broadcast.sent?
      redirect_to dashboard_broadcasts_path, alert: "Cannot delete sent broadcasts. You can unpublish them instead."
    else
      @broadcast.destroy
      redirect_to dashboard_broadcasts_path, notice: "Broadcast deleted successfully"
    end
  end

  def preview
    @broadcast = Broadcast.find(params[:id])
    BroadcastMailer.broadcast(user: Current.user, broadcast: @broadcast).deliver_later
    redirect_to dashboard_broadcasts_path, notice: "Preview sent to #{Current.user.email}"
  end

  private

  def set_broadcast
    @broadcast = Broadcast.find(params[:id])
  end

  def broadcast_params
    params.require(:broadcast).permit(:subject, :body, :scheduled_at, :draft, :recipient_type, :event_id, recipient_filters: {})
  end
end

class UnsubscribesController < ApplicationController
  allow_unauthenticated_access

  def show
    @user = User.find_by(unsubscribe_token: params[:token])
    if @user
      render Views::Unsubscribe::Show.new(user: @user, token: params[:token])
    else
      redirect_to root_path, alert: "Invalid unsubscribe link"
    end
  end

  def create
    @user = User.find_by(unsubscribe_token: params[:token])
    if @user
      # Record the unsubscribe event with optional reason (gracefully handle invalid reasons)
      @user.unsubscribe_events.create(reason: params[:reason].presence)
      @user.update!(newsletter: false)
      redirect_to unsubscribe_path(token: params[:token]), notice: "You have been successfully unsubscribed from newsletters"
    else
      redirect_to root_path, alert: "Invalid unsubscribe link"
    end
  end
end

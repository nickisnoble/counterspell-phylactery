class UsersController < ApplicationController
  def show
    @user = User.find_by_slug!(params.expect(:id))

    # Get past events the user attended with their heroes
    past_event_data = Seat
      .joins(game: :event, :hero)
      .where(user: @user, events: { status: "past" })
      .order("events.date DESC")
      .select("seats.*, events.*, heroes.name as hero_name")
      .group_by { |seat| seat.game.event }

    render Views::Users::Show.new(user: @user, past_event_data: past_event_data)
  end

  def edit
    @user = Current.user
    render Views::Users::Edit.new(user: @user)
  end

  def update
    @user = Current.user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to events_path, notice: "Profile was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render Views::Users::Edit.new(user: @user), status: :unprocessable_content }
        format.json { render json: @user.errors, status: :unprocessable_content }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:display_name, :bio, :pronouns, :newsletters)
    end
end

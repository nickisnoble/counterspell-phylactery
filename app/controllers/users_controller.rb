class UsersController < ApplicationController
  def show
    @user = User.find_by_slug!(params.expect(:id))
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def user_params
      params.require(:user)
    end
end

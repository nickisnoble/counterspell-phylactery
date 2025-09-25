class PagesController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      if Current.user.admin?
        redirect_to dashboard_path
      else
        redirect_to Current.user
      end
    else
      render :home
    end
  end

  def home
  end
end

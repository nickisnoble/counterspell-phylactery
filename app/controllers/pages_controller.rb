class PagesController < ApplicationController
  allow_unauthenticated_access

  def index
    unless authenticated?
      render :home
    else
      redirect_to Current.user
    end
  end

  def home
  end
end

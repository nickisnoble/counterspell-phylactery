class PagesController < ApplicationController
  allow_unauthenticated_access

  def index
    # TODO: Redirect to user dash if authed
    render :home
  end

  def home
  end
end

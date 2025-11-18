class NewslettersController < ApplicationController
  allow_unauthenticated_access

  def show
    @newsletter = Newsletter.published.find(params[:id])
    render Views::Newsletters::Show.new(newsletter: @newsletter)
  end
end

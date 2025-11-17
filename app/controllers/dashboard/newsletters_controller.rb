class Dashboard::NewslettersController < ApplicationController
  before_action :require_admin!
  before_action :set_newsletter, only: [:edit, :update, :destroy]

  def index
    @newsletters = Newsletter.all.order(scheduled_at: :desc)
    render Views::Dashboard::Newsletters::Index.new(newsletters: @newsletters)
  end

  def new
    @newsletter = Newsletter.new
    render Views::Dashboard::Newsletters::New.new(newsletter: @newsletter)
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)
    if @newsletter.save
      redirect_to dashboard_newsletters_path, notice: "Newsletter created successfully"
    else
      render Views::Dashboard::Newsletters::New.new(newsletter: @newsletter), status: :unprocessable_content
    end
  end

  def edit
    render Views::Dashboard::Newsletters::Edit.new(newsletter: @newsletter)
  end

  def update
    if @newsletter.update(newsletter_params)
      redirect_to dashboard_newsletters_path, notice: "Newsletter updated successfully"
    else
      render Views::Dashboard::Newsletters::Edit.new(newsletter: @newsletter), status: :unprocessable_content
    end
  end

  def destroy
    if @newsletter.sent?
      redirect_to dashboard_newsletters_path, alert: "Cannot delete sent newsletters. You can unpublish them instead."
    else
      @newsletter.destroy
      redirect_to dashboard_newsletters_path, notice: "Newsletter deleted successfully"
    end
  end

  private

  def set_newsletter
    @newsletter = Newsletter.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:subject, :body, :scheduled_at, :draft)
  end
end

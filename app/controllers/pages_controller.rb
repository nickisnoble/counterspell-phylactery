class PagesController < ApplicationController
  allow_unauthenticated_access only: :show
  before_action :require_admin!, except: :show
  before_action :set_page, only: %i[ show edit update destroy ]

  def index
    @pages = Page.all
    render Pages::Index.new(pages: @pages)
  end

  def show
    render Pages::Show.new(page: @page)
  end

  def new
    @page = Page.new
    render Pages::New.new(page: @page)
  end

  def edit
    render Pages::Edit.new(page: @page)
  end

  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: "Page was successfully created." }
        format.json { render :show, status: :created, location: @page }
      else
        format.html { render Pages::New.new(page: @page), status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1 or /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to @page, notice: "Page was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @page }
      else
        format.html { render Pages::Edit.new(page: @page), status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1 or /pages/1.json
  def destroy
    @page.destroy!

    respond_to do |format|
      format.html { redirect_to pages_path, notice: "Page was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find_by_slug!(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def page_params
      params.expect(page: [ :title, :slug, :body ])
    end
end

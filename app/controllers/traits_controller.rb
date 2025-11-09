class TraitsController < ApplicationController
  before_action :require_admin!, except: %i[ index show ]
  before_action :set_trait, only: %i[ show edit update destroy ]

  def index
    @traits = Trait.all
    render Views::Traits::Index.new(traits: @traits)
  end

  def show
    render Views::Traits::Show.new(trait: @trait, current_user: Current.user)
  end

  def new
    @trait = Trait.new
    render Views::Traits::New.new(trait: @trait)
  end

  def edit
    render Views::Traits::Edit.new(trait: @trait)
  end

  def create
    @trait = Trait.new(trait_params)

    respond_to do |format|
      if @trait.save
        format.html { redirect_to @trait, notice: "Trait was successfully created." }
        format.json {
          render json: {
            success: true,
            trait: {
              id: @trait.id,
              name: @trait.name,
              type: @trait.type
            }
          }, status: :created
        }
      else
        format.html do
          if turbo_frame_request?
            render Views::Traits::FormFrame.new(trait: @trait), status: :unprocessable_content, layout: false
          else
            render Views::Traits::New.new(trait: @trait), status: :unprocessable_content
          end
        end
        format.json {
          render json: {
            success: false,
            errors: @trait.errors.full_messages
          }, status: :unprocessable_content
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @trait.update(trait_params)
        format.html { redirect_to @trait, notice: "Trait was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @trait }
      else
        format.html do
          if turbo_frame_request?
            render Views::Traits::FormFrame.new(trait: @trait), status: :unprocessable_content, layout: false
          else
            render Views::Traits::Edit.new(trait: @trait), status: :unprocessable_content
          end
        end
        format.json { render json: @trait.errors, status: :unprocessable_content }
      end
    end
  end

  def destroy
    respond_to do |format|
      if 0 == @trait.heroes.count && @trait.destroy!
        format.html { redirect_to traits_path, notice: "Trait was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      else
        @trait.errors.add(:heroes, "still referenced by #{@trait.heroes.map(&:name).join(", ")}")
        format.html { render Views::Traits::Edit.new(trait: @trait), status: :unprocessable_content }
        format.json { render json: @trait.errors, status: :unprocessable_content }
      end
    end
  end

  private
    def set_trait
      @trait = Trait.find_by_slug!(params[:id])
    end

    def trait_params
      params.expect(trait: [ :type, :name, :description, :cover, abilities: {} ])
    end
end

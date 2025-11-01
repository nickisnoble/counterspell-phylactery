class HeroesController < ApplicationController
  before_action :require_admin!, except: [ :index, :show ]
  before_action :set_hero, only: %i[ show edit update destroy ]

  # GET /heroes or /heroes.json
  def index
    @heroes = Hero.all
    render Heroes::Index.new(heroes: @heroes)
  end

  # GET /heroes/1 or /heroes/1.json
  def show
    render Heroes::Show.new(hero: @hero, current_user: Current.user)
  end

  # GET /heroes/new
  def new
    @hero = Hero.new
    render Heroes::New.new(hero: @hero)
  end

  # GET /heroes/1/edit
  def edit
    render Heroes::Edit.new(hero: @hero)
  end

  # POST /heroes or /heroes.json
  def create
    @hero = Hero.new(hero_params)

    respond_to do |format|
      if @hero.save
        format.html { redirect_to @hero, notice: "Hero was successfully created." }
        format.json { render :show, status: :created, location: @hero }
      else
        format.html { render Heroes::New.new(hero: @hero), status: :unprocessable_content }
        format.json { render json: @hero.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /heroes/1 or /heroes/1.json
  def update
    respond_to do |format|
      if @hero.update(hero_params)
        format.html { redirect_to @hero, notice: "Hero was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @hero }
      else
        format.html { render Heroes::Edit.new(hero: @hero), status: :unprocessable_content }
        format.json { render json: @hero.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /heroes/1 or /heroes/1.json
  def destroy
    @hero.destroy!

    respond_to do |format|
      format.html { redirect_to heroes_path, notice: "Hero was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hero
      @hero = Hero.find_by_slug!(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hero_params
      permitted_params = params.expect(hero: [ :name, :pronouns, :role, :summary, :backstory, :portrait ])

      # Handle required trait assignments
      trait_ids = []

      trait_type_mappings = {
        "ANCESTRY" => "trait_ids_ancestry",
        "BACKGROUND" => "trait_ids_background",
        "CLASS" => "trait_ids_class"
      }

      Hero::REQUIRED_TRAIT_TYPES.each do |trait_type|
        trait_id_param = trait_type_mappings[trait_type]
        if params[trait_id_param].present?
          trait_ids << params[trait_id_param]
        end
      end

      # Add trait_ids to permitted params if any were selected
      permitted_params[:trait_ids] = trait_ids if trait_ids.any?

      permitted_params
    end
end

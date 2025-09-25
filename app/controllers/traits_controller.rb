class TraitsController < ApplicationController
  before_action :require_admin!, except: %i[ index show ]
  before_action :set_trait, only: %i[ show edit update destroy ]

  def index
    @traits = Trait.all
  end

  def show
  end

  def new
    @trait = Trait.new
  end

  def edit
  end

  def create
    @trait = Trait.new(trait_params)

    respond_to do |format|
      if @trait.save
        format.html { redirect_to @trait, notice: "Trait was successfully created." }
        format.json { render :show, status: :created, location: @trait }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @trait.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @trait.update(trait_params)
        format.html { redirect_to @trait, notice: "Trait was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @trait }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @trait.errors, status: :unprocessable_entity }
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
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @trait.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_trait
      @trait = Trait.find_by_slug!(params[:id])
    end

    def trait_params
      params.expect(trait: [ :type, :name, :description, :abilities ])
    end
end

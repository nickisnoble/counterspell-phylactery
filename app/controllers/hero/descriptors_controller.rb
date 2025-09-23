class Hero::DescriptorsController < ApplicationController
  before_action :require_admin!
  before_action :set_descriptor_type
  before_action :set_descriptor, only: %i[ show edit update destroy ]

  def index
    @descriptors = @descriptor_type.all
  end

  def show
  end

  def new
    @descriptor = @descriptor_type.new
  end

  def edit
  end

  def create
    @descriptor = @descriptor_type.new(descriptor_params)

    respond_to do |format|
      if @descriptor.save
        format.html { redirect_to url_for(action: :index), notice: "#{@descriptor_type.name.demodulize} was successfully created." }
        format.json { render :show, status: :created, location: @descriptor }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @descriptor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @descriptor.update(descriptor_params)
        format.html { redirect_to url_for(action: :index), notice: "#{@descriptor_type.name.demodulize} was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @descriptor }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @descriptor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @descriptor.destroy!

    respond_to do |format|
      format.html { redirect_to url_for(action: :index), notice: "#{@descriptor_type.name.demodulize} was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_descriptor_type
    type_param = params[:type]
    @descriptor_type = "Hero::#{type_param.classify}".constantize
  rescue NameError
    redirect_to root_path, alert: "Invalid descriptor type"
  end

  def set_descriptor
    @descriptor = @descriptor_type.all.find { |d| d.to_param == params[:id] }
    redirect_to root_path, alert: "#{@descriptor_type.name.demodulize} not found" unless @descriptor
  end

  def descriptor_params
    key = @descriptor_type.name.demodulize.underscore.to_sym
    if params[key]
      params.require(key).permit(:name, :description)
    else
      params.require(:hero_descriptor).permit(:name, :description)
    end
  end
end
# frozen_string_literal: true

class Views::Traits::FormFrame < Views::Base
  def initialize(trait:)
    @trait = trait
  end

  def view_template
    turbo_frame_tag :trait_form do
      render Views::Traits::FormComponent.new(trait: @trait)
    end
  end
end

# frozen_string_literal: true

class Views::Heroes::FormFrame < Views::Base
  def initialize(hero:)
    @hero = hero
  end

  def view_template
    turbo_frame_tag dom_id(@hero) do
      render Views::Heroes::FormComponent.new(hero: @hero)
    end
  end
end

# frozen_string_literal: true

class Views::Heroes::Hero < Views::Base
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  def initialize(hero:)
    @hero = hero
  end

  def view_template
    div(id: dom_id(@hero), class: "space-y-3 text-left") do
      div do
        if @hero.portrait.present?
          image_tag(url_for(@hero.portrait), class: "aspect-square object-cover object-top")
        end
        h3(class: "font-semibold text-gray-900 text-lg") { @hero.name }
        p(class: "mt-1 text-gray-600 text-sm") { "#{@hero.pronouns} • #{@hero.role.humanize}" }
        unsafe_raw @hero.summary.to_s
      end
      div do
        p(class: "mb-1 font-medium text-gray-700 text-sm") { "Traits:" }
        div(class: "flex flex-wrap gap-1") do
          @hero.traits.each do |trait|
            span(class: "inline-block bg-gray-100 px-2 py-1 rounded-md text-gray-700 text-xs") { trait.name }
          end
        end
      end
    end
  end
end

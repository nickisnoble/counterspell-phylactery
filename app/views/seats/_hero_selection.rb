# frozen_string_literal: true

class Views::Seats::HeroSelection < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  def initialize(game:, available_heroes:)
    @game = game
    @available_heroes = available_heroes
  end

  def view_template
    turbo_frame_tag "game_#{@game.id}_hero_selection" do
      div(class: "grid grid-cols-1 sm:grid-cols-2 gap-4", data: { wizard_target: "heroContainer" }) do
        @available_heroes.each do |hero|
          render_hero_option(hero)
        end
      end
    end
  end

  private

  def render_hero_option(hero)
    taken_hero_ids = @game.seats.where.not(hero_id: nil).pluck(:hero_id)
    is_taken = taken_hero_ids.include?(hero.id)

    label_class = "relative flex flex-col cursor-pointer rounded-sm border border-black/10 p-3 transition #{is_taken ? 'opacity-50' : 'hover:border-purple-500 hover:bg-white'} bg-white/50"

    label(class: label_class, data: { hero_role: hero.role, wizard_target: "heroOption" }) do
      input(
        type: "radio",
        name: "hero_id",
        value: hero.id,
        class: "peer sr-only",
        required: true,
        disabled: is_taken
      )

      # Selected indicator
      div(class: "absolute top-3 right-3 hidden peer-checked:block") do
        div(class: "w-6 h-6 bg-purple-900 rounded-full flex items-center justify-center") do
          i(class: "fa-solid fa-check text-white text-xs")
        end
      end

      # Hero portrait
      if hero.portrait.present?
        div(class: "aspect-square w-full mb-3 rounded-sm overflow-hidden bg-amber-100 border border-black/10") do
          image_tag(url_for(hero.portrait), class: "w-full h-full object-cover object-top")
        end
      else
        div(class: "aspect-square w-full mb-3 rounded-sm bg-amber-100 border border-black/10 flex items-center justify-center") do
          i(class: "fa-duotone fa-mask text-4xl text-purple-500")
        end
      end

      # Hero info
      p(class: "font-serif font-semibold text-sm text-blue-900 mb-1") { hero.name }
      p(class: "font-serif text-xs text-blue-900/60") do
        plain "#{hero.pronouns}"
        if hero.role
          plain " • #{hero.role.humanize}"
        end
      end
    end
  end
end

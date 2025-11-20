# frozen_string_literal: true

class Views::Seats::HeroSelection < Phlex::HTML
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::RadioButtonTag
  include Phlex::Rails::Helpers::ImageTag

  def initialize(game:, available_heroes:)
    @game = game
    @available_heroes = available_heroes
  end

  def view_template
    turbo_frame_tag "game_#{@game.id}_hero_selection" do
      div(class: "grid grid-cols-1 sm:grid-cols-2 gap-4", data: { wizard_target: "heroContainer" }) do
        taken_hero_ids = @game.seats.where.not(hero_id: nil).pluck(:hero_id)

        @available_heroes.each do |hero|
          render_hero_option(hero, taken_hero_ids.include?(hero.id))
        end
      end
    end
  end

  private

  def render_hero_option(hero, is_taken)
    label_class = "relative flex flex-col cursor-pointer rounded-sm border border-black/10 p-3 transition #{is_taken ? 'opacity-50' : 'hover:border-purple-500 hover:bg-white'} bg-white/50"

    label(class: label_class, data: { hero_role: hero.role, wizard_target: "heroOption" }) do
      radio_button_tag "hero_id", hero.id, false,
        class: "peer sr-only",
        required: true,
        disabled: is_taken,
        data: {
          action: "change->wizard#heroSelected",
          hero_name: hero.name
        }

      div(class: "absolute top-3 right-3 hidden peer-checked:block") do
        div(class: "w-6 h-6 bg-purple-900 rounded-full flex items-center justify-center") do
          i(class: "fa-solid fa-check text-white text-xs")
        end
      end

      if hero.portrait.present?
        div(class: "aspect-square w-full mb-3 rounded-sm overflow-hidden bg-amber-100 border border-black/10") do
          image_tag hero.portrait, class: "w-full h-full object-cover object-top"
        end
      else
        div(class: "aspect-square w-full mb-3 rounded-sm bg-amber-100 border border-black/10 flex items-center justify-center") do
          i(class: "fa-duotone fa-mask text-4xl text-purple-500")
        end
      end

      p(class: "font-serif font-semibold text-sm text-blue-900 mb-1") { hero.name }
      p(class: "font-serif text-xs text-blue-900/60") do
        plain hero.pronouns
        if hero.role
          plain " • #{hero.role.humanize}"
        end
      end
    end
  end
end

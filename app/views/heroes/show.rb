# frozen_string_literal: true

class Views::Heroes::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  def initialize(hero:)
    @hero = hero
  end

  def view_template
    content_for(:title, @hero.name)

    main(class: "mx-auto w-full max-w-4xl") do
      nav(class: "flex justify-center gap-3 p-4") do
        link_to("← Back to Heroes", heroes_path)
        link_to("Edit", edit_hero_path(@hero)) if Current.user.admin?
        if Current.user.admin?
          button_to(
            "Delete",
            @hero,
            class: "link",
            method: :delete,
            data: { turbo_confirm: "Are you sure you want to delete #{@hero.name}?" }
          )
        end
      end

      article(class: "paper") do
        div(class: "flex max-sm:flex-col items-start gap-6 text-left") do
          figure(class: "md:flex-1 bg-stone-100 shadow-md border-4 border-white w-full h-64") do
            image_tag(url_for(@hero.portrait)) if @hero.portrait.present?
          end

          div(class: "md:flex-2 space-y-4") do
            h1(class: "mb-2 font-bold text-gray-900 text-3xl") { @hero.name }
            p(class: "text-stone-500 text-sm") do
              plain "#{@hero.pronouns} • #{@hero.traits.map(&:name).join(' • ')} • #{@hero.role.humanize}"
            end

            raw @hero.backstory.to_s
          end
        end

        div(class: "*:last:-z-1 justify-center grid sm:grid-cols-3 *:shadow-md pt-4 border-current/20 border-t-2 *:first:-rotate-1 *:last:rotate-1") do
          @hero.traits.each do |trait|
            render Components::Card.from_trait(trait)
          end
        end
      end
    end
  end
end

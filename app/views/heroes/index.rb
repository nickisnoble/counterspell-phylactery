# frozen_string_literal: true

class Views::Heroes::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::Render

  def initialize(heroes:)
    @heroes = heroes
  end

  def view_template
    content_for(:title, "Heroes")

    main(class: "w-full") do
      div(class: "flex justify-between items-center mb-8") do
        h1(class: "font-bold text-4xl") { "Heroes" }
        link_to("New hero", new_hero_path, class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium")
      end

      div(id: "heroes") do
        if @heroes.any?
          div(class: "grid gap-6 md:grid-cols-2 lg:grid-cols-3") do
            @heroes.each do |hero|
              div(class: "bg-white rounded-lg border border-gray-200 p-6 hover:shadow-md transition-shadow") do
                render Views::Heroes::Hero.new(hero: hero)
                div(class: "flex flex-wrap gap-2 mt-4 pt-4 border-t border-gray-100") do
                  link_to("Show", hero, class: "text-sm px-3 py-1.5 bg-gray-100 hover:bg-gray-200 rounded-md font-medium transition-colors")
                  link_to("Edit", edit_hero_path(hero), class: "text-sm px-3 py-1.5 bg-gray-100 hover:bg-gray-200 rounded-md font-medium transition-colors")
                  button_to(
                    "Destroy",
                    hero,
                    method: :delete,
                    class: "text-sm px-3 py-1.5 bg-red-100 hover:bg-red-200 text-red-700 rounded-md font-medium cursor-pointer transition-colors",
                    data: { turbo_confirm: "Are you sure?" }
                  )
                end
              end
            end
          end
        else
          div(class: "text-center py-16") do
            p(class: "text-gray-500 text-lg") { "No heroes found." }
            link_to("Create your first hero", new_hero_path, class: "mt-4 inline-block rounded-md px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium")
          end
        end
      end
    end
  end
end

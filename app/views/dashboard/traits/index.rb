# frozen_string_literal: true

class Views::Dashboard::Traits::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::URLFor
  include ActionView::RecordIdentifier

  def initialize(traits:)
    @traits = traits
  end

  def view_template
    content_for(:title, "Traits")

    main(class: "w-full") do
      div(class: "flex justify-between items-center mb-8") do
        h1(class: "font-bold text-4xl") { "Traits" }
        link_to("New trait", new_dashboard_trait_path, class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium")
      end

      div(id: "traits", class: "container mx-auto") do
        if @traits.any?
          @traits.group_by(&:type).sort.each do |trait_type, traits_of_type|
            h2(class: "p-4 font-bold text-4xl border-b border-black/20 mb-8 mt-8") { trait_type.titleize.pluralize }

            ul(class: "grid md:grid-cols-3 lg:grid-cols-4 gap-6") do
              traits_of_type.each do |trait|
                li(class: "rounded-xl bg-amber-100 block") do
                  nav(class: "flex gap-2 px-2 py-1 opacity-50") do
                    link_to("Edit", edit_dashboard_trait_path(trait))
                    link_to("View", dashboard_trait_path(trait))
                  end

                  cover_url = trait.cover.attached? ? url_for(trait.cover) : nil
                  render Components::Card.new(
                    title: trait.name,
                    cover: cover_url,
                    dom_id: dom_id(trait),
                    badge: trait.type
                  ) do
                    p(class: "font-light italic text-pretty leading-snug") { trait.description }

                    if trait.abilities.present? && trait.abilities.any?
                      ul(class: "space-y-2 text-xs") do
                        trait.abilities.each do |name, description|
                          li do
                            strong(class: "font-black text-[0.8em] uppercase") { "#{name}:" }
                            whitespace
                            plain description
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        else
          div(class: "text-center py-16") do
            p(class: "text-gray-500 text-lg") { "No traits found." }
            link_to("Create your first trait", new_dashboard_trait_path, class: "mt-4 inline-block rounded-md px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium")
          end
        end
      end
    end
  end
end

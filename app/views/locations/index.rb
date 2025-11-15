# frozen_string_literal: true

class Views::Locations::Index < Views::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ContentFor

  def initialize(locations:)
    @locations = locations
  end

  def view_template
    content_for(:title, "Venues")

    main(class: "w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      h1(class: "font-bold text-4xl mb-8") { "Venues" }

      if @locations.any?
        div(class: "grid gap-6 md:grid-cols-2 lg:grid-cols-3") do
          @locations.each do |location|
            render_location_card(location)
          end
        end
      else
        div(class: "bg-gray-50 rounded-lg p-8 text-center") do
          p(class: "text-gray-600") { "No venues available yet." }
        end
      end
    end
  end

  private

  def render_location_card(location)
    link_to(location_path(location), class: "block") do
      div(class: "bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow") do
        div(class: "flex items-start mb-3") do
          span(class: "text-3xl mr-3") { "📍" }
          div do
            h2(class: "font-bold text-xl text-gray-900") { location.name }
          end
        end

        if location.address.present?
          p(class: "text-gray-600 text-sm") { location.address }
        end

        event_count = location.events.publicly_visible.count
        if event_count > 0
          div(class: "mt-4 pt-4 border-t border-gray-200") do
            p(class: "text-sm text-gray-500") do
              "#{event_count} #{'event'.pluralize(event_count)}"
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Views::Dashboard::Locations::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(locations:)
    @locations = locations
  end

  def view_template
    content_for(:title, "Admin - Locations")

    main(class: "w-full max-w-6xl mx-auto px-4 py-8") do
      div(class: "flex justify-between items-center mb-6") do
        h1(class: "font-bold text-3xl") { "Locations" }
        link_to("+ New Location", new_dashboard_location_path, class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
      end

      div(id: "locations", class: "container mx-auto") do
        if @locations.any?
          div(class: "bg-white shadow-md rounded-lg overflow-hidden") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Name" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Address" }
                  th(class: "px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider") { "Actions" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @locations.each do |location|
                  tr do
                    td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900") { location.name }
                    td(class: "px-6 py-4 text-sm text-gray-500") { location.address }
                    td(class: "px-6 py-4 whitespace-nowrap text-right text-sm") do
                      link_to("Edit", edit_dashboard_location_path(location), class: "text-blue-600 hover:text-blue-800 mr-3")
                      button_to("Delete", dashboard_location_path(location), method: :delete, form: { data: { turbo_confirm: "Are you sure?" } }, class: "text-gray-500 hover:text-red-600")
                    end
                  end
                end
              end
            end
          end
        else
          div(class: "bg-white rounded-lg border border-gray-200 text-center py-16") do
            p(class: "text-gray-500 mb-4") { "No locations yet." }
            link_to("+ Create First Location", new_dashboard_location_path, class: "inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
          end
        end
      end
    end
  end
end

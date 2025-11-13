# frozen_string_literal: true

class Views::Admin::Locations::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(locations:)
    @locations = locations
  end

  def view_template
    content_for(:title, "Admin - Locations")

    main(class: "w-full") do
      div(class: "flex justify-between items-center mb-8") do
        h1(class: "font-bold text-4xl") { "Locations" }
        link_to("New location", new_admin_location_path, class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium")
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
                    td(class: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium") do
                      link_to("Edit", edit_admin_location_path(location), class: "text-blue-600 hover:text-blue-900 mr-4")
                      button_to("Delete", admin_location_path(location), method: :delete, form: { data: { turbo_confirm: "Are you sure?" } }, class: "text-red-600 hover:text-red-900")
                    end
                  end
                end
              end
            end
          end
        else
          div(class: "text-center py-16") do
            p(class: "text-gray-500 text-lg") { "No locations found." }
            link_to("Create your first location", new_admin_location_path, class: "mt-4 inline-block rounded-md px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium")
          end
        end
      end
    end
  end
end

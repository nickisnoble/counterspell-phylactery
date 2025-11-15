# frozen_string_literal: true

class Views::Dashboards::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    content_for(:title, "Dashboard")

    main(class: "w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      h1(class: "font-bold text-3xl mb-8") { "Dashboard" }

      div(class: "bg-white rounded-lg shadow-md divide-y divide-gray-200") do
        render_link("Events", "fa-calendar", dashboard_events_path)
        render_link("Locations", "fa-location-dot", dashboard_locations_path)
        render_link("Heroes", "fa-mask", heroes_path)
        render_link("Traits", "fa-star", dashboard_traits_path)
        render_link("Check-in", "fa-qrcode", check_in_path)
      end
    end
  end

  private

  def render_link(title, icon, path)
    link_to(path, class: "flex items-center justify-between p-4 hover:bg-gray-50 transition group") do
      div(class: "flex items-center") do
        i(class: "fa-solid #{icon} text-blue-600 text-xl w-8")
        span(class: "ml-4 font-medium text-gray-900") { title }
      end
      i(class: "fa-solid fa-chevron-right text-gray-400 group-hover:text-gray-600")
    end
  end
end

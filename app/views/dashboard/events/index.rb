# frozen_string_literal: true

class Views::Dashboard::Events::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(events:)
    @events = events
  end

  def view_template
    content_for(:title, "Admin - Events")

    main(class: "w-full max-w-7xl mx-auto px-4 py-8") do
      div(class: "flex justify-between items-center mb-6") do
        h1(class: "font-bold text-3xl") { "Events" }
        link_to("+ New Event", new_dashboard_event_path, class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
      end

      div(id: "events", class: "container mx-auto") do
        if @events.any?
          div(class: "bg-white shadow-md rounded-lg overflow-hidden") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Name" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Date" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Location" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Status" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Games" }
                  th(class: "px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider") { "Actions" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @events.each do |event|
                  tr do
                    td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900") { event.name }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") { event.date.strftime("%B %d, %Y") }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") { event.location.name }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
                      span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_badge_class(event.status)}") do
                        event.status&.titleize || "Unknown"
                      end
                    end
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") { event.games.count }
                    td(class: "px-6 py-4 whitespace-nowrap text-right text-sm") do
                      link_to("Edit", edit_dashboard_event_path(event), class: "text-blue-600 hover:text-blue-800 mr-3")
                      button_to("Delete", dashboard_event_path(event), method: :delete, form: { data: { turbo_confirm: "Are you sure?" } }, class: "text-gray-500 hover:text-red-600")
                    end
                  end
                end
              end
            end
          end
        else
          div(class: "bg-white rounded-lg border border-gray-200 text-center py-16") do
            p(class: "text-gray-500 mb-4") { "No events yet." }
            link_to("+ Create First Event", new_dashboard_event_path, class: "inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
          end
        end
      end
    end
  end

  private

  def status_badge_class(status)
    case status
    when "planning"
      "bg-yellow-100 text-yellow-800"
    when "upcoming"
      "bg-green-100 text-green-800"
    when "past"
      "bg-gray-100 text-gray-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end

# frozen_string_literal: true

class Views::Dashboard::Broadcasts::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(broadcasts:)
    @broadcasts = broadcasts
  end

  def view_template
    content_for(:title, "Admin - Broadcasts")

    main(class: "w-full max-w-7xl mx-auto px-4 py-8") do
      div(class: "flex justify-between items-center mb-6") do
        h1(class: "font-bold text-3xl") { "Broadcasts" }
        link_to("+ New Broadcast", new_dashboard_broadcast_path, class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
      end

      div(id: "broadcasts", class: "container mx-auto") do
        if @broadcasts.any?
          div(class: "bg-white shadow-md rounded-lg overflow-hidden") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Subject" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Type" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Scheduled" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Status" }
                  th(class: "px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider") { "Actions" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @broadcasts.each do |broadcast|
                  tr do
                    td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900") { broadcast.subject }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") { broadcast.recipient_type.humanize }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") { broadcast.scheduled_at.strftime("%b %d, %Y at %I:%M %p") }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
                      if broadcast.sent?
                        span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800") { "Sent" }
                      elsif broadcast.draft?
                        span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800") { "Draft" }
                      else
                        span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800") { "Scheduled" }
                      end
                    end
                    td(class: "px-6 py-4 whitespace-nowrap text-right text-sm space-x-2") do
                      button_to("Preview", preview_dashboard_broadcast_path(broadcast), method: :post, class: "text-purple-600 hover:text-purple-800")
                      link_to("Edit", edit_dashboard_broadcast_path(broadcast), class: "text-blue-600 hover:text-blue-800")
                      unless broadcast.sent?
                        button_to("Delete", dashboard_broadcast_path(broadcast), method: :delete, form: { data: { turbo_confirm: "Are you sure?" } }, class: "text-gray-500 hover:text-red-600")
                      end
                    end
                  end
                end
              end
            end
          end
        else
          div(class: "bg-white rounded-lg border border-gray-200 text-center py-16") do
            p(class: "text-gray-500 mb-4") { "No broadcasts yet." }
            link_to("+ Create First Broadcast", new_dashboard_broadcast_path, class: "inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
          end
        end
      end
    end
  end
end

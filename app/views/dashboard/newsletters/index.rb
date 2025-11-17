# frozen_string_literal: true

class Views::Dashboard::Newsletters::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(newsletters:)
    @newsletters = newsletters
  end

  def view_template
    content_for(:title, "Admin - Newsletters")

    main(class: "w-full max-w-7xl mx-auto px-4 py-8") do
      div(class: "flex justify-between items-center mb-6") do
        h1(class: "font-bold text-3xl") { "Newsletters" }
        link_to("+ New Newsletter", new_dashboard_newsletter_path, class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
      end

      div(id: "newsletters", class: "container mx-auto") do
        if @newsletters.any?
          div(class: "bg-white shadow-md rounded-lg overflow-hidden") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Subject" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Scheduled" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Status" }
                  th(class: "px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider") { "Actions" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @newsletters.each do |newsletter|
                  tr do
                    td(class: "px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900") { newsletter.subject }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") { newsletter.scheduled_at.strftime("%B %d, %Y at %I:%M %p") }
                    td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
                      if newsletter.sent?
                        span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800") { "Sent" }
                      elsif newsletter.draft?
                        span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800") { "Draft" }
                      else
                        span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800") { "Scheduled" }
                      end
                    end
                    td(class: "px-6 py-4 whitespace-nowrap text-right text-sm") do
                      link_to("Edit", edit_dashboard_newsletter_path(newsletter), class: "text-blue-600 hover:text-blue-800 mr-3")
                      unless newsletter.sent?
                        button_to("Delete", dashboard_newsletter_path(newsletter), method: :delete, form: { data: { turbo_confirm: "Are you sure?" } }, class: "text-gray-500 hover:text-red-600")
                      end
                    end
                  end
                end
              end
            end
          end
        else
          div(class: "bg-white rounded-lg border border-gray-200 text-center py-16") do
            p(class: "text-gray-500 mb-4") { "No newsletters yet." }
            link_to("+ Create First Newsletter", new_dashboard_newsletter_path, class: "inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Views::Dashboard::Broadcasts::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(broadcast:, events:)
    @broadcast = broadcast
    @events = events
  end

  def view_template
    form_with(model: @broadcast, url: @broadcast.persisted? ? dashboard_broadcast_path(@broadcast) : dashboard_broadcasts_path, class: "max-w-3xl") do |form|
      if @broadcast.errors.any?
        div(id: "error_explanation", class: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-6") do
          h2(class: "font-semibold mb-2") { "#{pluralize(@broadcast.errors.count, 'error')} prohibited this broadcast from being saved:" }
          ul(class: "list-disc ml-5 text-sm space-y-1") do
            @broadcast.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
        div(class: "space-y-5") do
          div do
            form.label :subject, class: "block text-sm font-medium text-gray-700 mb-2"
            form.text_field :subject, class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500", placeholder: "Broadcast subject line"
          end

          div do
            form.label :body, class: "block text-sm font-medium text-gray-700 mb-2"
            form.rich_text_area :body, class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          end

          div do
            form.label :scheduled_at, "Scheduled to send at", class: "block text-sm font-medium text-gray-700 mb-2"
            form.datetime_field :scheduled_at, class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          end

          div do
            form.label :recipient_type, "Send to", class: "block text-sm font-medium text-gray-700 mb-2"
            form.select :recipient_type,
              [
                ["All subscribers", "all_subscribers"],
                ["Event attendees", "event_attendees"],
                ["Filtered recipients", "filtered"]
              ],
              {},
              class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500",
              data: { action: "change->broadcast#updateRecipientType" }
          end

          # Event selection (shown when event_attendees is selected)
          div(data: { broadcast_target: "eventField" }, class: "hidden") do
            form.label :event_id, "Event", class: "block text-sm font-medium text-gray-700 mb-2"
            form.select :event_id,
              @events.map { |e| [e.name, e.id] },
              { prompt: "Select an event" },
              class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          end

          # Filtering options (shown when filtered is selected)
          div(data: { broadcast_target: "filterFields" }, class: "hidden") do
            p(class: "text-sm text-gray-600 mb-3") { "Select one or more filters:" }

            div(class: "space-y-3 pl-4 border-l-2 border-gray-200") do
              # Role filter
              div do
                label(class: "block text-sm font-medium text-gray-700 mb-2") { "By role:" }
                div(class: "space-y-1") do
                  ["player", "gm", "staff", "admin"].each do |role|
                    label(class: "flex items-center gap-2") do
                      input(type: "checkbox", name: "broadcast[recipient_filters][roles][]", value: role, class: "rounded border-gray-300 text-blue-600 shadow-sm focus:border-blue-500 focus:ring-blue-500")
                      span(class: "text-sm text-gray-700") { role.capitalize }
                    end
                  end
                end
              end

              # Event attendance filter
              div do
                label(class: "block text-sm font-medium text-gray-700 mb-2") { "By event attendance:" }
                div(class: "space-y-2") do
                  label(class: "flex items-center gap-2") do
                    input(type: "radio", name: "broadcast[recipient_filters][attendance_filter]", value: "any", class: "rounded-full border-gray-300 text-blue-600 shadow-sm")
                    span(class: "text-sm text-gray-700") { "Attended any event" }
                  end
                  label(class: "flex items-center gap-2") do
                    input(type: "radio", name: "broadcast[recipient_filters][attendance_filter]", value: "never", class: "rounded-full border-gray-300 text-blue-600 shadow-sm")
                    span(class: "text-sm text-gray-700") { "Never attended" }
                  end
              label(class: "flex items-center gap-2") do
                input(type: "radio", name: "broadcast[recipient_filters][attendance_filter]", value: "specific", class: "rounded-full border-gray-300 text-blue-600 shadow-sm")
                span(class: "text-sm text-gray-700") { "Attended specific event:" }
              end
              div(data: { controller: "event-search" }, class: "ml-6") do
                input(type: "hidden", name: "broadcast[recipient_filters][attended_event_id]", data: { "event-search-target": "hidden" })
                input(
                  type: "text",
                  placeholder: "Search events by name",
                  list: "event-search-options",
                  class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500",
                  data: {
                    "action": "input->event-search#search change->event-search#select blur->event-search#select",
                    "event-search-target": "input",
                    "event-search-url-value": search_dashboard_events_path
                  }
                )
                datalist(id: "event-search-options", data: { "event-search-target": "list" })
              end
            end
          end

          # Name/email search filter
          div do
                label(class: "block text-sm font-medium text-gray-700 mb-2") { "By name or email:" }
                input(type: "text", name: "broadcast[recipient_filters][name_search]", placeholder: "Search by name or email", class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500")
              end
            end
          end

          div do
            form.label :draft, class: "flex items-center gap-2"
            form.check_box :draft, class: "rounded border-gray-300 text-blue-600 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            span(class: "text-sm text-gray-700") { "Save as draft (will not send automatically)" }
          end
        end
      end

      div(class: "flex gap-4") do
        form.submit "Save Broadcast", class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition"
      end
    end
  end
end

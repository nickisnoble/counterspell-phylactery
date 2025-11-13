# frozen_string_literal: true

class Views::Admin::Events::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::OptionsForSelect

  def initialize(event:, locations:)
    @event = event
    @locations = locations
  end

  def view_template
    form_with(model: @event, url: @event.persisted? ? admin_event_path(@event) : admin_events_path, class: "contents text-left") do |form|
      if @event.errors.any?
        div(id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3") do
          h2 { "#{pluralize(@event.errors.count, 'error')} prohibited this event from being saved:" }

          ul(class: "list-disc ml-6") do
            @event.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "my-5") do
        form.label :name
        form.text_field :name, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "my-5") do
        form.label :date
        form.date_field :date, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "my-5") do
        form.label :location_id, "Location"
        form.collection_select :location_id, @locations, :id, :name, { prompt: "Select a location" }, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "my-5") do
        form.label :status
        form.select :status,
          [["Planning", "planning"], ["Upcoming", "upcoming"], ["Past", "past"], ["Cancelled", "cancelled"]],
          { prompt: "Select status" },
          class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "grid grid-cols-2 gap-4") do
        div(class: "my-5") do
          form.label :start_time, "Start time"
          form.time_field :start_time, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
        end

        div(class: "my-5") do
          form.label :end_time, "End time"
          form.time_field :end_time, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
        end
      end

      div(class: "my-5") do
        form.label :ticket_price, "Ticket price ($)"
        form.number_field :ticket_price, step: 0.01, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "my-5") do
        form.label :description
        form.rich_text_area :description, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div do
        form.submit class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-medium cursor-pointer"
      end
    end
  end
end

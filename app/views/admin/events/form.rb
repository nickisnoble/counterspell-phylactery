# frozen_string_literal: true

class Views::Admin::Events::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::OptionsForSelect

  def initialize(event:, locations:, gms:)
    @event = event
    @locations = locations
    @gms = gms
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

      # Nested Games Fields
      div(class: "my-8") do
        h3(class: "font-bold text-2xl mb-4") { "Games (Tables)" }
        p(class: "text-gray-600 text-sm mb-4") { "Add game tables with GMs for this event. Default is 3 tables with 5 seats each." }

        div(id: "games-fields") do
          form.fields_for :games do |game_form|
            render_game_fields(game_form)
          end
        end
      end

      div do
        form.submit class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-medium cursor-pointer"
      end
    end
  end

  private

  def render_game_fields(game_form)
    div(class: "p-4 mb-4 bg-gray-50 rounded-md border border-gray-200") do
      div(class: "grid grid-cols-2 gap-4") do
        div do
          game_form.label :gm_id, "Game Master"
          game_form.collection_select :gm_id, @gms, :id, :display_name,
            { prompt: "Select GM" },
            class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
        end

        div do
          game_form.label :seat_count, "Number of Seats"
          game_form.number_field :seat_count,
            min: 1,
            max: 10,
            class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
        end
      end

      unless game_form.object.new_record?
        div(class: "mt-3") do
          game_form.check_box :_destroy, class: "mr-2"
          game_form.label :_destroy, "Remove this game", class: "text-sm text-red-600"
        end
      end
    end
  end
end

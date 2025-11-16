# frozen_string_literal: true

class Views::Dashboard::Events::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::OptionsForSelect
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(event:, locations:, gms:)
    @event = event
    @locations = locations
    @gms = gms
  end

  def view_template
    form_with(model: @event, url: @event.persisted? ? dashboard_event_path(@event) : dashboard_events_path, class: "max-w-3xl") do |form|
      if @event.errors.any?
        div(id: "error_explanation", class: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-6") do
          h2(class: "font-semibold mb-2") { "#{pluralize(@event.errors.count, 'error')} prohibited this event from being saved:" }
          ul(class: "list-disc ml-5 text-sm space-y-1") do
            @event.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      # Basic Details Section
      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
        h3(class: "font-semibold text-lg mb-6 pb-3 border-b border-gray-200") { "Basic Details" }

        div(class: "space-y-5") do
          div do
            render_label(form, :name, "Event Name", "fa-calendar")
            form.text_field :name, class: input_classes, placeholder: "e.g., Summer Adventure Night"
          end

          div(class: "grid grid-cols-2 gap-4") do
            div do
              render_label(form, :date, "Date", "fa-calendar-day")
              form.date_field :date, class: input_classes
            end

            div do
              render_label(form, :status, "Status", "fa-circle-dot")
              form.select :status,
                [["Planning", "planning"], ["Upcoming", "upcoming"], ["Past", "past"], ["Cancelled", "cancelled"]],
                { prompt: "Select status" },
                class: input_classes
            end
          end

          div(class: "grid grid-cols-2 gap-4") do
            div do
              render_label(form, :start_time, "Start Time", "fa-clock")
              form.time_field :start_time, class: input_classes
            end

            div do
              render_label(form, :end_time, "End Time", "fa-clock")
              form.time_field :end_time, class: input_classes
            end
          end

          div do
            render_label(form, :ticket_price, "Ticket Price ($)", "fa-dollar-sign")
            form.number_field :ticket_price, step: 0.01, class: input_classes, placeholder: "0.00"
          end
        end
      end

      # Location Section
      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
        h3(class: "font-semibold text-lg mb-6 pb-3 border-b border-gray-200") { "Location" }

        div(data: { controller: "inline-location" }) do
          div(class: "flex gap-3") do
            div(class: "flex-1") do
              form.collection_select :location_id, @locations, :id, :name,
                { prompt: "Select a location" },
                class: input_classes,
                data: { inline_location_target: "select" }
            end

            button(
              type: "button",
              class: "px-4 py-2 border border-gray-300 hover:border-gray-400 bg-white hover:bg-gray-50 text-gray-700 rounded-md text-sm transition",
              data: { action: "click->inline-location#toggle", inline_location_target: "toggle" }
            ) { "+ New" }
          end

          # Inline location creation form
          div(class: "mt-4 p-4 bg-gray-50 rounded-md border border-gray-200 hidden",
              data: { inline_location_target: "form" },
              id: "inline-location-form") do
            h4(class: "font-medium mb-4 text-sm text-gray-900") { "Create New Location" }

            form_with(model: Location.new, url: dashboard_locations_path, class: "space-y-4") do |location_form|
              div do
                location_form.label :name, class: "block text-sm font-medium text-gray-700 mb-2"
                location_form.text_field :name,
                  class: input_classes,
                  placeholder: "e.g., The Game Haven"
              end

              div do
                location_form.label :address, class: "block text-sm font-medium text-gray-700 mb-2"
                location_form.text_area :address,
                  rows: 2,
                  class: input_classes,
                  placeholder: "123 Main St, City, State"
              end

              div(class: "flex gap-2 pt-2") do
                button(
                  type: "button",
                  class: "px-3 py-2 border border-gray-300 hover:border-gray-400 bg-white hover:bg-gray-50 text-gray-700 rounded-md text-sm transition",
                  data: { action: "click->inline-location#cancel" }
                ) { "Cancel" }

                location_form.submit "Create Location", class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm transition"
              end
            end
          end
        end
      end

      # Description Section
      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
        h3(class: "font-semibold text-lg mb-6 pb-3 border-b border-gray-200") { "Description" }

        form.rich_text_area :description, class: "block w-full rounded-md border border-gray-200 mt-1"
      end

      # Games Section
      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6", data: { controller: "nested-form" }) do
        div(class: "mb-6 pb-3 border-b border-gray-200") do
          h3(class: "font-semibold text-lg mb-1") { "Game Tables" }
          p(class: "text-sm text-gray-600") { "Add game tables with GMs for this event." }
        end

        div(class: "space-y-3", data: { nested_form_target: "container" }) do
          form.fields_for :games do |game_form|
            render_game_fields(game_form)
          end
        end

        button(
          type: "button",
          class: "mt-2 px-4 py-2 border border-gray-300 hover:border-gray-400 bg-white hover:bg-gray-50 text-gray-700 rounded-md text-sm transition",
          data: { action: "click->nested-form#add" }
        ) { "+ Add Table" }

        # Template for new game fields
        template(data: { nested_form_target: "template" }) do
          render_game_template(form)
        end
      end

      # Seats Section (only show for persisted events with seats)
      if @event.persisted? && @event.seats.where.not(user_id: nil).exists?
        div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
          div(class: "mb-6 pb-3 border-b border-gray-200") do
            h3(class: "font-semibold text-lg mb-1") { "Manage Seats" }
            p(class: "text-sm text-gray-600") { "Reassign seats to different game tables." }
          end

          div(class: "space-y-3") do
            @event.seats.where.not(user_id: nil).includes(:user, :hero, :game).each do |seat|
              form.fields_for :seats, seat do |seat_form|
                render_seat_fields(seat_form, seat)
              end
            end
          end
        end
      end

      # Submit Button
      div(class: "flex gap-3") do
        form.submit class: "px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium rounded-md cursor-pointer"
      end
    end
  end

  private

  def input_classes
    "block w-full rounded-md border border-gray-300 px-3 py-2.5 text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition"
  end

  def render_label(form, field, text, icon)
    form.label field, class: "block text-sm font-medium text-gray-700 mb-2" do
      span { text }
    end
  end

  def render_game_fields(game_form)
    div(
      class: "nested-fields relative p-4 bg-gray-50 rounded-md border border-gray-200",
      data: { new_record: game_form.object.new_record?.to_s }
    ) do
      game_form.hidden_field :_destroy

      # X button in top right corner
      button(
        type: "button",
        class: "absolute top-2 right-2 w-6 h-6 flex items-center justify-center text-gray-400 hover:text-gray-600 hover:bg-gray-200 rounded transition",
        data: { action: "click->nested-form#remove" },
        title: "Remove"
      ) { "×" }

      div(class: "grid grid-cols-2 gap-4") do
        div do
          game_form.label :gm_id, "Game Master", class: "block text-sm font-medium text-gray-700 mb-2"
          game_form.collection_select :gm_id, @gms, :id, :display_name,
            { prompt: "Select GM" },
            class: input_classes
        end

        div do
          game_form.label :seat_count, "Seats", class: "block text-sm font-medium text-gray-700 mb-2"
          game_form.number_field :seat_count,
            min: 1,
            max: 10,
            value: game_form.object.seat_count || 5,
            class: input_classes
        end
      end
    end
  end

  def render_game_template(form)
    form.fields_for :games, Game.new, child_index: "NEW_RECORD" do |game_form|
      div(
        class: "nested-fields relative p-4 bg-gray-50 rounded-md border border-gray-200",
        data: { new_record: "true" }
      ) do
        game_form.hidden_field :_destroy

        # X button in top right corner
        button(
          type: "button",
          class: "absolute top-2 right-2 w-6 h-6 flex items-center justify-center text-gray-400 hover:text-gray-600 hover:bg-gray-200 rounded transition",
          data: { action: "click->nested-form#remove" },
          title: "Remove"
        ) { "×" }

        div(class: "grid grid-cols-2 gap-4") do
          div do
            game_form.label :gm_id, "Game Master", class: "block text-sm font-medium text-gray-700 mb-2"
            game_form.collection_select :gm_id, @gms, :id, :display_name,
              { prompt: "Select GM" },
              class: input_classes
          end

          div do
            game_form.label :seat_count, "Seats", class: "block text-sm font-medium text-gray-700 mb-2"
            game_form.number_field :seat_count,
              min: 1,
              max: 10,
              value: 5,
              class: input_classes
          end
        end
      end
    end
  end

  def render_seat_fields(seat_form, seat)
    div(class: "p-4 bg-gray-50 rounded-md border border-gray-200") do
      seat_form.hidden_field :id

      div(class: "grid grid-cols-3 gap-4 items-center") do
        # Player/Hero info
        div(class: "col-span-2") do
          div(class: "font-medium text-sm text-gray-900") do
            plain seat.user.display_name
            if seat.hero
              plain " - "
              span(class: "text-gray-600") { seat.hero.name }
            end
          end
          div(class: "text-xs text-gray-500 mt-1") do
            plain "Currently at: "
            span(class: "font-medium") { seat.game.gm.display_name }
            plain "'s table"
          end
          if seat.stripe_payment_intent_id.present?
            div(class: "text-xs mt-1") do
              a(
                href: "https://dashboard.stripe.com/payments/#{seat.stripe_payment_intent_id}",
                target: "_blank",
                rel: "noopener noreferrer",
                class: "text-blue-600 hover:text-blue-800 flex items-center gap-1"
              ) do
                i(class: "fa-solid fa-external-link text-xs")
                plain "View Stripe Transaction"
              end
            end
          end
        end

        # Game reassignment
        div do
          seat_form.collection_select :game_id,
            @event.games,
            :id,
            ->(game) { "#{game.gm.display_name}'s table" },
            {},
            class: input_classes
        end
      end
    end
  end
end

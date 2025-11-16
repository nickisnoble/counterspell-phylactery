# frozen_string_literal: true

class Views::Checkins::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  register_output_helper :turbo_stream_from

  def initialize(attendees:, events:)
    @attendees = attendees
    @events = events
  end

  def view_template
    content_for(:title, "Check-in")

    # Subscribe to turbo streams for all today's events
    @events.each do |event|
      turbo_stream_from(event)
    end

    main(class: "w-full max-w-6xl mx-auto px-4 py-8 bg-amber-50 min-h-screen") do
      h1(class: "font-display text-4xl text-blue-900 mb-8") { "Check-in" }

      # QR Scanner section
      div(class: "bg-white rounded-sm border border-black/10 p-6 mb-8") do
        h2(class: "font-display text-2xl text-blue-900 mb-4") { "QR Scanner" }

        form_with(url: checkin_path, method: :post, class: "space-y-4") do |f|
          div do
            f.label :token, "Scan or enter ticket token:", class: "block font-serif font-medium mb-2 text-blue-900"
            f.text_field :token,
              required: true,
              placeholder: "Token from QR code",
              autofocus: true,
              class: "block w-full px-4 py-2 border border-black/10 rounded-sm font-mono text-sm"
          end

          f.submit "Check In",
            class: "btn w-full font-serif font-semibold cursor-pointer"
        end
      end

      # Attendees table
      if @attendees.any?
        div(class: "bg-white rounded-sm border border-black/10 p-6", data: { controller: "search" }) do
          div(class: "flex justify-between items-center mb-6") do
            h2(class: "font-display text-2xl text-blue-900") { "Today's Attendees" }

            checked_in_count = @attendees.count(&:checked_in?)
            p(class: "text-sm font-serif text-blue-900/60") do
              "#{checked_in_count} / #{@attendees.count} checked in"
            end
          end

          # Search input
          input(
            type: "text",
            placeholder: "Search by name, hero, or GM...",
            class: "w-full px-4 py-2 mb-4 border border-black/10 rounded-sm font-serif text-sm",
            data: { search_target: "input", action: "input->search#filter" }
          )

          # Attendees table
          div(class: "overflow-x-auto") do
            table(class: "min-w-full", data: { search_target: "table" }) do
              thead(class: "bg-amber-50 border-b border-black/10") do
                tr do
                  th(class: "px-4 py-3 text-left text-xs font-serif font-medium text-blue-900/80 uppercase") { "Player" }
                  th(class: "px-4 py-3 text-left text-xs font-serif font-medium text-blue-900/80 uppercase") { "Hero" }
                  th(class: "px-4 py-3 text-left text-xs font-serif font-medium text-blue-900/80 uppercase") { "Event" }
                  th(class: "px-4 py-3 text-left text-xs font-serif font-medium text-blue-900/80 uppercase") { "GM" }
                  th(class: "px-4 py-3 text-left text-xs font-serif font-medium text-blue-900/80 uppercase") { "Status" }
                  th(class: "px-4 py-3 text-left text-xs font-serif font-medium text-blue-900/80 uppercase") { "Action" }
                end
              end

              tbody(class: "bg-white divide-y divide-black/5") do
                @attendees.each do |seat|
                  render_attendee_row(seat)
                end
              end
            end
          end
        end
      else
        div(class: "bg-white rounded-sm border border-black/10 p-8 text-center") do
          p(class: "font-serif text-blue-900/60") { "No events scheduled for today" }
        end
      end
    end
  end

  private

  def render_attendee_row(seat)
    tr do
      td(class: "px-4 py-3 whitespace-nowrap") do
        div(class: "text-sm font-serif font-medium text-blue-900") { seat.user.display_name }
        div(class: "text-xs font-serif text-blue-900/60") { seat.user.email }
      end

      td(class: "px-4 py-3 whitespace-nowrap text-sm font-serif text-blue-900") do
        seat.hero ? seat.hero.name : "-"
      end

      td(class: "px-4 py-3 whitespace-nowrap text-sm font-serif text-blue-900") do
        seat.game.event.name
      end

      td(class: "px-4 py-3 whitespace-nowrap text-sm font-serif text-blue-900") do
        seat.game.gm.display_name
      end

      td(class: "px-4 py-3 whitespace-nowrap") do
        if seat.checked_in?
          span(class: "px-2 py-1 inline-flex items-center gap-1 text-xs font-serif font-semibold rounded-full bg-emerald-100 text-emerald-800 border border-emerald-200") do
            i(class: "fa-solid fa-check text-xs")
            plain "Checked in"
          end
          if seat.checked_in_at
            div(class: "text-xs font-serif text-blue-900/60 mt-1") do
              seat.checked_in_at.strftime("%I:%M %p")
            end
          end
        else
          span(class: "px-2 py-1 text-xs font-serif font-semibold rounded-full bg-amber-100 text-amber-800 border border-amber-200") do
            "Not checked in"
          end
        end
      end

      td(class: "px-4 py-3 whitespace-nowrap text-sm") do
        render Views::Components::CheckinButton.new(seat: seat, variant: :compact)
      end
    end
  end
end

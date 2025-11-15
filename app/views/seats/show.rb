# frozen_string_literal: true

class Views::Seats::Show < Views::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ContentFor

  def initialize(seat:, game:, event:)
    @seat = seat
    @game = game
    @event = event
  end

  def view_template
    content_for(:title, "Your Ticket - #{@event.name}")

    main(class: "w-full max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      # Ticket header
      div(class: "bg-gradient-to-r from-blue-600 to-purple-600 rounded-t-lg p-8 text-white") do
        h1(class: "font-bold text-3xl mb-2") { "Event Ticket" }
        p(class: "text-blue-100") { "Your seat has been confirmed!" }
      end

      # Ticket body
      div(class: "bg-white rounded-b-lg shadow-xl p-8") do
        # Event details
        div(class: "mb-8") do
          h2(class: "font-bold text-2xl text-gray-900 mb-4") { @event.name }

          div(class: "space-y-3 text-gray-700") do
            div(class: "flex items-start") do
              span(class: "mr-3 text-2xl") { "📅" }
              div do
                div(class: "font-semibold") { "Date & Time" }
                div { @event.date.strftime("%A, %B %d, %Y") }
                if @event.start_time
                  div(class: "text-sm text-gray-600") do
                    "#{@event.start_time.strftime('%I:%M %p')}#{@event.end_time ? " - #{@event.end_time.strftime('%I:%M %p')}" : ''}"
                  end
                end
              end
            end

            div(class: "flex items-start") do
              span(class: "mr-3 text-2xl") { "📍" }
              div do
                div(class: "font-semibold") { "Location" }
                div { @event.location.name }
                if @event.location.address
                  div(class: "text-sm text-gray-600") { @event.location.address }
                end
              end
            end

            div(class: "flex items-start") do
              span(class: "mr-3 text-2xl") { "🎲" }
              div do
                div(class: "font-semibold") { "Game Master" }
                div { @game.gm.display_name }
                div(class: "text-sm text-gray-600") { "Table #{@game.id}" }
              end
            end

            if @seat.hero
              div(class: "flex items-start") do
                span(class: "mr-3 text-2xl") { "🎭" }
                div do
                  div(class: "font-semibold") { "Your Hero" }
                  div { @seat.hero.name }
                  if @seat.hero.role
                    div(class: "text-sm text-gray-600") { @seat.hero.role.titleize }
                  end
                end
              end
            end
          end
        end

        # QR Code for check-in
        div(class: "border-2 border-gray-200 rounded-lg p-8 text-center mb-6 bg-white") do
          div(class: "inline-block p-4 bg-white") do
            qr_code = RQRCode::QRCode.new(@seat.qr_code_url)
            unsafe_raw qr_code.as_svg(
              module_size: 4,
              standalone: true,
              use_path: true,
              color: "000",
              shape_rendering: "crispEdges"
            )
          end
          p(class: "text-gray-600 font-mono text-sm mt-4") { "Ticket ##{@seat.id}" }
          p(class: "text-gray-500 text-xs mt-2") { "Scan this QR code at check-in" }
        end

        # Payment info
        if @seat.purchased_at
          div(class: "text-sm text-gray-500 text-center pt-6 border-t border-gray-200") do
            "Purchased on #{@seat.purchased_at.strftime('%B %d, %Y at %I:%M %p')}"
          end
        end
      end

      # Actions
      div(class: "mt-6 flex gap-4") do
        link_to("← Back to Event", event_path(@event),
          class: "flex-1 text-center px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50 transition")

        link_to("View All My Tickets", user_seats_path(Current.user),
          class: "flex-1 text-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-500 transition")
      end
    end
  end
end

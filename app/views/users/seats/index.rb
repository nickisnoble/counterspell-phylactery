# frozen_string_literal: true

class Views::Users::Seats::Index < Views::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ContentFor

  def initialize(user:, upcoming_seats:, past_seats:)
    @user = user
    @upcoming_seats = upcoming_seats
    @past_seats = past_seats
  end

  def view_template
    content_for(:title, "My Tickets")

    main(class: "w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      h1(class: "font-bold text-4xl mb-8") { "My Tickets" }

      # Upcoming events
      if @upcoming_seats.any?
        div(class: "bg-white rounded-lg shadow-md p-8 mb-6") do
          h2(class: "font-bold text-2xl mb-6") { "Upcoming Events" }
          div(class: "space-y-4") do
            @upcoming_seats.each do |seat|
              render_seat_card(seat)
            end
          end
        end
      end

      # Past events
      if @past_seats.any?
        div(class: "bg-white rounded-lg shadow-md p-8") do
          h2(class: "font-bold text-2xl mb-6") { "Past Events" }
          div(class: "space-y-4") do
            @past_seats.each do |seat|
              render_seat_card(seat)
            end
          end
        end
      end

      # No tickets message
      if @upcoming_seats.empty? && @past_seats.empty?
        div(class: "bg-yellow-50 rounded-lg p-8 text-center") do
          p(class: "text-yellow-800 mb-4") { "You haven't purchased any tickets yet." }
          link_to("Browse Events", events_path,
            class: "inline-block px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white font-medium rounded-md transition")
        end
      end
    end
  end

  private

  def render_seat_card(seat)
    event = seat.game.event

    link_to(user_seat_path(@user, seat), class: "block") do
      div(class: "border border-gray-200 rounded-lg p-6 hover:border-blue-400 hover:shadow-lg transition") do
        div(class: "flex justify-between items-start mb-4") do
          div do
            h3(class: "font-bold text-xl text-gray-900") { event.name }
            p(class: "text-gray-600 mt-1") { event.date.strftime("%A, %B %d, %Y") }
            if event.start_time
              p(class: "text-gray-500 text-sm") { event.start_time.strftime("%I:%M %p") }
            end
          end

          span(class: "text-4xl") { "🎫" }
        end

        div(class: "grid md:grid-cols-2 gap-4 text-sm") do
          div do
            div(class: "font-semibold text-gray-700") { "Location" }
            div(class: "text-gray-600") { event.location.name }
          end

          div do
            div(class: "font-semibold text-gray-700") { "Game Master" }
            div(class: "text-gray-600") { seat.game.gm.display_name }
          end

          if seat.hero
            div do
              div(class: "font-semibold text-gray-700") { "Your Hero" }
              div(class: "text-gray-600") { seat.hero.name }
            end
          end

          div do
            div(class: "font-semibold text-gray-700") { "Ticket ID" }
            div(class: "text-gray-600 font-mono") { "##{seat.id}" }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Views::Events::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(event:, current_user: nil, user_heroes: [])
    @event = event
    @current_user = current_user
    @user_heroes = user_heroes
  end

  def view_template
    content_for(:title, @event.name)

    main(class: "w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      # Back link
      div(class: "mb-6") do
        link_to("← Back to Events", events_path, class: "text-blue-600 hover:text-blue-800")
      end

      # Event header
      div(class: "bg-white rounded-lg shadow-md p-8 mb-6") do
        div(class: "flex justify-between items-start mb-4") do
          h1(class: "font-bold text-4xl text-gray-900") { @event.name }
          span(class: "px-4 py-2 text-sm font-semibold rounded-full #{status_badge_class(@event.status)}") do
            @event.status&.titleize || "Unknown"
          end
        end

        div(class: "grid md:grid-cols-2 gap-6 mt-6") do
          # Left column - event details
          div do
            h2(class: "font-bold text-xl mb-4") { "Event Details" }
            div(class: "space-y-3 text-gray-700") do
              div(class: "flex items-center") do
                span(class: "mr-3 text-2xl") { "📅" }
                div do
                  div(class: "font-semibold") { "Date" }
                  div { @event.date.strftime("%A, %B %d, %Y") }
                end
              end

              if @event.start_time
                div(class: "flex items-center") do
                  span(class: "mr-3 text-2xl") { "🕐" }
                  div do
                    div(class: "font-semibold") { "Time" }
                    div { "#{@event.start_time.strftime('%I:%M %p')}#{@event.end_time ? " - #{@event.end_time.strftime('%I:%M %p')}" : ''}" }
                  end
                end
              end

              div(class: "flex items-center") do
                span(class: "mr-3 text-2xl") { "📍" }
                div do
                  div(class: "font-semibold") { "Location" }
                  div { @event.location.name }
                  div(class: "text-sm text-gray-500") { @event.location.address }
                end
              end

              if @event.ticket_price && @event.ticket_price > 0
                div(class: "flex items-center") do
                  span(class: "mr-3 text-2xl") { "💵" }
                  div do
                    div(class: "font-semibold") { "Ticket Price" }
                    div(class: "text-2xl font-bold text-green-600") { "$#{@event.ticket_price}" }
                  end
                end
              end
            end
          end

          # Right column - description
          if @event.description.present?
            div do
              h2(class: "font-bold text-xl mb-4") { "About This Event" }
              div(class: "prose max-w-none") do
                render @event.description
              end
            end
          end
        end
      end

      # Games/Tables section
      if @event.games.any?
        div(class: "bg-white rounded-lg shadow-md p-8") do
          h2(class: "font-bold text-2xl mb-6") { "Game Tables" }
          p(class: "text-gray-600 mb-6") { "#{@event.games.count} #{'table'.pluralize(@event.games.count)} available for this event" }

          div(class: "grid gap-4 md:grid-cols-2 lg:grid-cols-3") do
            @event.games.each do |game|
              render_game_card(game)
            end
          end
        end
      else
        div(class: "bg-yellow-50 rounded-lg p-6 text-center") do
          p(class: "text-yellow-800") { "Game tables are still being organized. Check back soon!" }
        end
      end
    end
  end

  private

  def render_game_card(game)
    available_seats = game.seat_count - game.seats.where.not(user_id: nil).count

    div(class: "bg-gray-50 rounded-lg p-6 border border-gray-200") do
      div(class: "flex items-center mb-4") do
        span(class: "text-3xl mr-3") { "🎲" }
        div do
          div(class: "font-semibold text-lg") { "Game Master" }
          div(class: "text-gray-700") { game.gm.display_name }
        end
      end

      div(class: "space-y-2 text-sm text-gray-600") do
        div(class: "flex items-center") do
          span(class: "mr-2") { "💺" }
          span { "#{game.seat_count} #{'seat'.pluralize(game.seat_count)}" }
        end
        div(class: "flex items-center") do
          span(class: "mr-2") { available_seats > 0 ? "✅" : "❌" }
          span(class: available_seats > 0 ? "text-green-600 font-semibold" : "text-red-600") do
            if available_seats > 0
              "#{available_seats} #{'seat'.pluralize(available_seats)} available"
            else
              "Table full"
            end
          end
        end
      end

      # Purchase button
      if available_seats > 0 && @event.upcoming? && @current_user
        div(class: "mt-4") do
          if @user_heroes.any?
            form_with(url: game_seats_path(game), method: :post) do |f|
              f.select :hero_id, @user_heroes.map { |h| [h.name, h.id] },
                { prompt: "Select your hero" },
                class: "block w-full rounded-md border-gray-300 mb-2"

              f.submit "Purchase Seat ($#{@event.ticket_price})",
                class: "block w-full text-center rounded-md px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium cursor-pointer"
            end
          else
            link_to("Create a Hero First", new_hero_path,
              class: "block w-full text-center rounded-md px-4 py-2 bg-gray-400 text-white font-medium")
          end
        end
      elsif available_seats > 0 && @event.upcoming?
        div(class: "mt-4") do
          link_to("Sign In to Purchase", new_session_path,
            class: "block w-full text-center rounded-md px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium")
        end
      end
    end
  end

  def status_badge_class(status)
    case status
    when "upcoming"
      "bg-green-100 text-green-800"
    when "past"
      "bg-gray-100 text-gray-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    else
      "bg-yellow-100 text-yellow-800"
    end
  end
end

# frozen_string_literal: true

class Views::Games::Show < Views::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTo

  register_output_helper :turbo_stream_from

  def initialize(game:, event:, available_seats:, seats:, current_user:, is_today: false, is_gm_or_admin: false)
    @game = game
    @event = event
    @available_seats = available_seats
    @seats = seats
    @current_user = current_user
    @is_today = is_today
    @is_gm_or_admin = is_gm_or_admin
  end

  def view_template
    content_for(:title, "#{@event.name} - #{@game.gm.display_name}'s Table")

    # Subscribe to turbo streams for realtime updates
    turbo_stream_from(@event) if @is_gm_or_admin

    main(class: "w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      # Back link
      div(class: "mb-6") do
        link_to("← Back to #{@event.name}", event_path(@event), class: "text-blue-600 hover:text-blue-800")
      end

      # Game header
      div(class: "bg-white rounded-lg shadow-md p-8 mb-6") do
        div(class: "flex items-start mb-4") do
          span(class: "text-4xl mr-4") { "🎲" }
          div do
            h1(class: "font-bold text-3xl text-gray-900") { "Table #{@game.id}" }
            p(class: "text-gray-600 text-lg mt-2") { "Game Master: #{@game.gm.display_name}" }
          end
        end

        div(class: "mt-6 grid md:grid-cols-2 gap-4") do
          div(class: "flex items-center") do
            span(class: "mr-3 text-2xl") { "💺" }
            div do
              div(class: "font-semibold") { "Seats" }
              div(class: "text-gray-600") { "#{@game.seat_count} total" }
            end
          end

          div(class: "flex items-center") do
            span(class: "mr-3 text-2xl") { @available_seats > 0 ? "✅" : "❌" }
            div do
              div(class: "font-semibold") { "Availability" }
              div(class: @available_seats > 0 ? "text-green-600 font-semibold" : "text-red-600") do
                if @available_seats > 0
                  "#{@available_seats} #{'seat'.pluralize(@available_seats)} available"
                else
                  "Table full"
                end
              end
            end
          end
        end

        # Purchase button
        if @available_seats > 0 && @event.upcoming? && @current_user
          div(class: "mt-6 pt-6 border-t border-gray-200") do
            user_heroes = Hero.all
            if user_heroes.any?
              form_with(url: event_game_seats_path(@event, @game), method: :post) do |f|
                div(class: "flex gap-4") do
                  f.select :hero_id, user_heroes.map { |h| [h.name, h.id] },
                    { prompt: "Select your hero" },
                    class: "flex-1 rounded-md border-gray-300"

                  f.submit "Purchase Seat ($#{@event.ticket_price})",
                    class: "px-6 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium rounded-md cursor-pointer"
                end
              end
            else
              link_to("Create a Hero First", new_hero_path,
                class: "block w-full text-center rounded-md px-4 py-2 bg-gray-400 text-white font-medium")
            end
          end
        elsif @available_seats > 0 && @event.upcoming?
          div(class: "mt-6 pt-6 border-t border-gray-200") do
            link_to("Sign In to Purchase", new_session_path,
              class: "block w-full text-center rounded-md px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium")
          end
        end
      end

      # Seated players
      if @seats.any?
        div(class: "bg-white rounded-lg shadow-md p-8") do
          h2(class: "font-bold text-2xl mb-6") { "Seated Players" }
          div(class: "space-y-3") do
            @seats.each do |seat|
              render_seat(seat)
            end
          end
        end
      end
    end
  end

  private

  def render_seat(seat)
    if @is_gm_or_admin
      render_detailed_seat(seat)
    else
      render_simple_seat(seat)
    end
  end

  def render_simple_seat(seat)
    div(class: "flex items-center justify-between border-b border-gray-200 pb-3") do
      div(class: "flex items-center") do
        span(class: "text-2xl mr-3") { "🎭" }
        div do
          if seat.hero
            div(class: "font-semibold") { seat.hero.name }
            if seat.user
              div(class: "text-sm text-gray-600") { "Played by #{seat.user.display_name}" }
            end
          elsif seat.user
            div(class: "font-semibold") { seat.user.display_name }
            div(class: "text-sm text-gray-600") { "Hero TBD" }
          end
        end
      end
    end
  end

  def render_detailed_seat(seat)
    div(class: "border border-gray-200 rounded-md p-4 bg-gray-50") do
      div(class: "flex items-start justify-between") do
        # Player and Hero info
        div(class: "flex-1") do
          # Player details
          div(class: "mb-3") do
            div(class: "font-semibold text-lg text-gray-900") { seat.user.display_name }
            if seat.user.pronouns.present?
              div(class: "text-sm text-gray-600") { seat.user.pronouns }
            end
            if seat.user.email.present?
              div(class: "text-sm text-gray-500") { seat.user.email }
            end
          end

          # Hero details
          if seat.hero
            div(class: "mt-3 pt-3 border-t border-gray-300") do
              div(class: "font-medium text-gray-900 mb-1") { "Playing: #{seat.hero.name}" }
              if seat.hero.pronouns.present?
                div(class: "text-sm text-gray-600 mb-1") { seat.hero.pronouns }
              end
              if seat.hero.role.present?
                div(class: "text-sm text-gray-600 capitalize") { "Role: #{seat.hero.role.humanize}" }
              end
            end
          end

          # User bio
          if seat.user.bio.present?
            div(class: "mt-3 pt-3 border-t border-gray-300") do
              div(class: "text-sm font-medium text-gray-700 mb-1") { "Bio:" }
              div(class: "prose prose-sm max-w-none text-gray-600") do
                render seat.user.bio
              end
            end
          end
        end

        # Checkin button (only for today's games)
        if @is_today && can_check_in?(seat)
          div(class: "ml-4") do
            if seat.checked_in?
              div do
                div(class: "mb-2 text-sm font-medium text-emerald-700") { "Checked in" }
                if seat.checked_in_at
                  div(class: "mb-2 text-xs text-gray-500") { seat.checked_in_at.strftime("%I:%M %p") }
                end
                button_to(
                  "Undo",
                  checkin_seat_path(seat),
                  method: :patch,
                  class: "px-3 py-1 bg-gray-600 hover:bg-gray-700 text-white text-sm font-medium rounded-md cursor-pointer"
                )
              end
            else
              button_to(
                "Check In",
                checkin_seat_path(seat),
                method: :patch,
                class: "px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white font-medium rounded-md cursor-pointer"
              )
            end
          end
        elsif @is_today
          div(class: "ml-4") do
            if seat.checked_in?
              div(class: "text-sm font-medium text-emerald-700") { "Checked in" }
              if seat.checked_in_at
                div(class: "text-xs text-gray-500 mt-1") { seat.checked_in_at.strftime("%I:%M %p") }
              end
            end
          end
        end
      end
    end
  end

  def can_check_in?(seat)
    return true if @current_user&.admin?
    @current_user&.id == @game.gm_id
  end
end

# frozen_string_literal: true

class Views::Events::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  register_output_helper :turbo_stream_from

  def initialize(event:, current_user: nil, available_heroes: [])
    @event = event
    @current_user = current_user
    @available_heroes = available_heroes
  end

  def view_template
    content_for(:title, @event.name)

    turbo_stream_from(@event)

    main(class: "w-full max-w-3xl mx-auto px-4 py-12 bg-amber-50 min-h-screen") do
      # Back link and checkin button
      div(class: "mb-8 flex justify-between items-center") do
        link_to("← Back to Events", events_path, class: "font-serif text-purple-900 hover:text-purple-700 font-medium transition")

        if @current_user && (@current_user.admin? || @current_user.gm?)
          link_to("Check-in Management", checkin_path, class: "btn px-4 py-2 font-serif font-semibold text-sm")
        end
      end

      # Event masthead - flex layout with auto-width sidebar
      div(class: "mb-12 flex flex-col lg:flex-row gap-8") do
        # Main content: Title, status, and description (left-aligned, flex-grow)
        div(class: "flex-grow space-y-6 text-left") do
          # Title and status
          div(class: "space-y-3") do
            h1(class: "font-display text-5xl text-blue-900 text-left") { @event.name }
            span(class: "inline-block px-3 py-1 text-xs font-serif font-semibold rounded-full #{status_badge_class(@event.status)}") do
              @event.status&.titleize || "Unknown"
            end
          end

          # Description
          if @event.description.present?
            div(class: "prose prose-lg max-w-none font-serif text-blue-900/80 text-left") do
              render @event.description
            end
          end
        end

        # Sidebar: Sticky sidebar with event details and CTA (auto-width)
        div(class: "w-max flex-shrink-0") do
          div(class: "lg:sticky lg:top-8 space-y-4 w-max") do
            # Event details card
            div(class: "border border-black/10 rounded-sm bg-white/70 p-4 space-y-3 min-w-[280px]") do
              # Date
              div(class: "flex items-start gap-2") do
                i(class: "fa-duotone fa-calendar-days text-base text-emerald-500 shrink-0 mt-0.5")
                div(class: "text-sm font-serif text-blue-900/80 font-medium text-left") do
                  @event.date.strftime('%A, %B %d, %Y')
                end
              end

              # Time
              if @event.start_time
                div(class: "flex items-start gap-2") do
                  i(class: "fa-duotone fa-clock text-base text-blue-500 shrink-0 mt-0.5")
                  div(class: "text-sm font-serif text-blue-900/80 text-left") do
                    plain @event.start_time.strftime('%-l:%M %p')
                    if @event.end_time
                      plain " - #{@event.end_time.strftime('%-l:%M %p')}"
                    end
                  end
                end
              end

              # Location (with full address)
              div(class: "flex items-start gap-2") do
                i(class: "fa-duotone fa-location-dot text-base text-pink-500 shrink-0 mt-0.5")
                div(class: "text-sm font-serif text-blue-900/80 text-left") do
                  div(class: "font-medium") { @event.location.name }
                  div(class: "text-xs text-blue-900/60 mt-0.5") { @event.location.address }
                end
              end

              # Ticket Price
              if @event.ticket_price && @event.ticket_price > 0
                div(class: "flex items-start gap-2 pt-2 border-t border-black/5") do
                  i(class: "fa-duotone fa-coins text-base text-amber-500 shrink-0 mt-0.5")
                  div(class: "text-sm font-serif text-blue-900/80 text-left") do
                    plain "Tickets: "
                    span(class: "font-display text-lg text-purple-900") { "$#{@event.ticket_price}" }
                  end
                end
              end
            end

            # CTA Button - only for upcoming events with available seats
            if @event.upcoming? && has_available_seats?
              if @current_user
                a(href: "#games", class: "btn w-full") do
                  "Get Tickets"
                end
              else
                link_to(new_session_path, class: "btn w-full") do
                  "Sign In to Get Tickets"
                end
              end
            end
          end
        end
      end

      # Games/Tables section
      if @event.games.any?
        div(id: "games", class: "mb-12") do
          h2(class: "font-display text-3xl text-blue-900 mb-6") { "Game Tables" }

          div(class: "space-y-6") do
            @event.games.each do |game|
              render_game_card(game)
            end
          end
        end
      else
        div(class: "py-8 text-center") do
          p(class: "font-serif text-blue-900/60") { "Game tables are still being organized. Check back soon!" }
        end
      end
    end
  end

  private

  def has_available_seats?
    @event.games.any? do |game|
      game.seats.where(user_id: nil).exists?
    end
  end

  def render_game_card(game)
    filled_seats = game.seats.where.not(user_id: nil).includes(:user, :hero)
    available_seats = game.seat_count - filled_seats.count

    div(class: "border border-black/10 rounded-sm bg-white/50 overflow-hidden") do
      div(class: "grid md:grid-cols-2 gap-6 p-6") do
        # Left: GM info
        div(class: "space-y-4") do
          # GM header
          div do
            div(class: "flex items-center gap-2 mb-2") do
              i(class: "fa-duotone fa-dice-d20 text-xl text-purple-500")
              h3(class: "font-serif font-semibold text-lg text-blue-900") { game.gm.display_name }
            end
            div(class: "text-sm font-serif text-blue-900/60") do
              plain "#{game.seat_count} #{'seat'.pluralize(game.seat_count)} • "
              if available_seats > 0
                span(class: "text-emerald-700") { "#{available_seats} available" }
              else
                span(class: "text-rose-700") { "Full" }
              end
            end
          end

          # GM bio
          if game.gm.bio.present?
            div(class: "prose prose-sm max-w-none font-serif text-blue-900/70") do
              render game.gm.bio
            end
          end
        end

        # Right: Seats grid
        div do
          div(class: "grid grid-cols-2 gap-3") do
            # Render filled seats
            filled_seats.each do |seat|
              render_filled_seat(seat)
            end

            # Render empty seats
            available_seats.times do
              render_empty_seat(game)
            end
          end
        end
      end
    end
  end

  def render_filled_seat(seat)
    div(class: "border border-black/10 rounded-sm p-3 bg-white min-h-[5rem] flex flex-col justify-center") do
      div(class: "flex items-center gap-2 mb-1") do
        i(class: "fa-solid fa-user text-sm text-purple-500")
        span(class: "font-serif font-medium text-sm text-blue-900 truncate") { seat.user.display_name }
      end
      if seat.hero
        div(class: "flex items-center gap-2 text-xs font-serif text-blue-900/60") do
          i(class: "fa-solid fa-mask text-xs")
          span(class: "truncate") { seat.hero.name }
        end
      end
    end
  end

  def render_empty_seat(game)
    # Only make clickable if event is upcoming and user can purchase
    if @event.upcoming? && @current_user
      link_to(new_event_game_seat_path(@event, game), class: "border border-dashed border-black/20 rounded-sm p-3 bg-amber-50/50 hover:bg-white hover:border-purple-500 transition flex items-center justify-center min-h-[5rem] group") do
        div(class: "text-center") do
          i(class: "fa-solid fa-plus text-purple-500/60 group-hover:text-purple-500 text-sm mb-1")
          div(class: "text-xs font-serif text-blue-900/60 group-hover:text-blue-900") { "Purchase" }
        end
      end
    elsif @event.upcoming?
      link_to(new_session_path, class: "border border-dashed border-black/20 rounded-sm p-3 bg-amber-50/50 hover:bg-white hover:border-purple-500 transition flex items-center justify-center min-h-[5rem] group") do
        div(class: "text-center") do
          i(class: "fa-solid fa-right-to-bracket text-purple-500/60 group-hover:text-purple-500 text-sm mb-1")
          div(class: "text-xs font-serif text-blue-900/60 group-hover:text-blue-900") { "Sign In" }
        end
      end
    else
      div(class: "border border-dashed border-black/10 rounded-sm p-3 bg-amber-50/30 flex items-center justify-center min-h-[5rem]") do
        div(class: "text-xs font-serif text-blue-900/40") { "Empty" }
      end
    end
  end

  def status_badge_class(status)
    case status
    when "upcoming"
      "bg-emerald-100 text-emerald-800 border border-emerald-200"
    when "past"
      "bg-amber-100 text-amber-800 border border-amber-200"
    when "cancelled"
      "bg-rose-100 text-rose-800 border border-rose-200"
    else
      "bg-purple-100 text-purple-800 border border-purple-200"
    end
  end
end

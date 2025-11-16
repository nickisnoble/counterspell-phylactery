# frozen_string_literal: true

class Views::Events::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(events:)
    @events = events
  end

  def view_template
    content_for(:title, "Events")

    main(class: "w-full px-4 py-12 bg-amber-50 min-h-screen") do
      div(class: "max-w-3xl mx-auto", data: { controller: "events-filter" }) do
        # Header with toggle
        div(class: "mb-12") do
          div(class: "flex justify-between items-start mb-6") do
            h1(class: "font-display text-5xl text-blue-900") { "Events" }

            # Status toggle tabs
            render_status_tabs
          end

          p(class: "font-serif text-lg text-blue-900/80") do
            "Join us for unforgettable adventures. Each event features multiple game tables led by experienced GMs."
          end
        end

        if @events.any?
          # Separate sections by status
          upcoming_events = @events.select(&:upcoming?)
          past_events = @events.select(&:past?)
          cancelled_events = @events.select(&:cancelled?)
          planning_events = @events.select { |e| e.status == "planning" }

          # Upcoming section
          if upcoming_events.any?
            div(data: { events_filter_target: "section", status: "upcoming" }, class: "space-y-8") do
              upcoming_by_date = upcoming_events.group_by { |e| e.date.to_date }
              upcoming_by_date.each do |date, events|
                render_date_group(date, events)
              end
            end
          end

          # Past section
          if past_events.any?
            div(data: { events_filter_target: "section", status: "past" }, class: "space-y-8") do
              h2(class: "font-display text-3xl text-blue-900 mb-8") { "Past Events" }
              past_by_date = past_events.group_by { |e| e.date.to_date }
              past_by_date.each do |date, events|
                render_date_group(date, events)
              end
            end
          end

          # Planning section (GMs/admins only)
          if planning_events.any?
            div(data: { events_filter_target: "section", status: "planning" }, class: "space-y-8") do
              h2(class: "font-display text-3xl text-blue-900 mb-8") { "Planning" }
              planning_by_date = planning_events.group_by { |e| e.date.to_date }
              planning_by_date.each do |date, events|
                render_date_group(date, events)
              end
            end
          end

          # Cancelled section (GMs/admins only)
          if cancelled_events.any?
            div(data: { events_filter_target: "section", status: "cancelled" }, class: "space-y-8") do
              h2(class: "font-display text-3xl text-blue-900 mb-8") { "Cancelled" }
              cancelled_by_date = cancelled_events.group_by { |e| e.date.to_date }
              cancelled_by_date.each do |date, events|
                render_date_group(date, events)
              end
            end
          end
        else
          render_empty_state
        end
      end
    end
  end

  private

  def render_status_tabs
    div(class: "flex gap-2") do
      # Upcoming tab
      button(
        data: { events_filter_target: "tab", status: "upcoming", action: "click->events-filter#filter" },
        class: "px-4 py-2 font-serif text-sm font-medium rounded-sm transition cursor-pointer"
      ) do
        "Upcoming"
      end

      # Past tab
      button(
        data: { events_filter_target: "tab", status: "past", action: "click->events-filter#filter" },
        class: "px-4 py-2 font-serif text-sm font-medium rounded-sm transition cursor-pointer"
      ) do
        "Past"
      end

      # Planning tab (only if planning events exist)
      if @events.any? { |e| e.status == "planning" }
        button(
          data: { events_filter_target: "tab", status: "planning", action: "click->events-filter#filter" },
          class: "px-4 py-2 font-serif text-sm font-medium rounded-sm transition cursor-pointer"
        ) do
          "Planning"
        end
      end

      # Cancelled tab (only if cancelled events exist)
      if @events.any?(&:cancelled?)
        button(
          data: { events_filter_target: "tab", status: "cancelled", action: "click->events-filter#filter" },
          class: "px-4 py-2 font-serif text-sm font-medium rounded-sm transition cursor-pointer"
        ) do
          "Cancelled"
        end
      end
    end
  end

  def render_date_group(date, events)
    div(class: "flex gap-6") do
      # Left: Date
      div(class: "flex-shrink-0 w-24 pt-2") do
        div(class: "font-display text-3xl text-blue-900") { date.strftime('%b %d') }
        div(class: "font-serif text-sm text-blue-900/60") { date.strftime('%A') }
      end

      # Right: Events for this date
      div(class: "flex-grow space-y-4") do
        events.each do |event|
          render_timeline_event_card(event)
        end
      end
    end
  end

  def render_timeline_event_card(event)
    total_seats = calculate_total_seats(event)
    available_seats = calculate_available_seats(event)
    sold_out = available_seats == 0
    is_past = event.past?
    is_cancelled = event.cancelled?

    # Determine card styling
    card_opacity = (is_past || is_cancelled) ? "opacity-75" : ""
    card_bg = is_cancelled ? "bg-rose-50/50" : "bg-white"

    div(class: "#{card_bg} rounded-sm shadow-md border border-black/10 hover:shadow-lg transition-all #{card_opacity}") do
      div(class: "grid lg:grid-cols-3 gap-6 p-6") do
        # Main column: Title and description
        div(class: "lg:col-span-2 space-y-4 text-left") do
          # Title
          h3(class: "font-display text-3xl text-blue-900 #{is_cancelled ? 'line-through' : ''}") do
            event.name
          end

          # Description
          if event.description.present?
            div(class: "prose prose-lg max-w-none font-serif text-blue-900/80") do
              render event.description
            end
          end
        end

        # Sticky sidebar: Event details and CTA
        div(class: "lg:col-span-1") do
          div(class: "lg:sticky lg:top-8 space-y-4") do
            # Event details card
            div(class: "border border-black/10 rounded-sm bg-white/70 p-4 space-y-3") do
              # Date
              div(class: "flex items-start gap-2") do
                i(class: "fa-duotone fa-calendar-days text-base text-emerald-500 shrink-0 mt-0.5")
                div(class: "text-sm font-serif text-blue-900/80 font-medium text-left") do
                  event.date.strftime('%b %d, %Y')
                end
              end

              # Time
              if event.start_time
                div(class: "flex items-start gap-2") do
                  i(class: "fa-duotone fa-clock text-base text-blue-500 shrink-0 mt-0.5")
                  div(class: "text-sm font-serif text-blue-900/80 text-left") do
                    plain event.start_time.strftime('%-l:%M %p')
                    if event.end_time
                      plain " - #{event.end_time.strftime('%-l:%M %p')}"
                    end
                  end
                end
              end

              # Location
              div(class: "flex items-start gap-2") do
                i(class: "fa-duotone fa-location-dot text-base text-pink-500 shrink-0 mt-0.5")
                div(class: "text-sm font-serif text-blue-900/80 font-medium text-left") do
                  event.location.name
                end
              end

              # Tables
              div(class: "flex items-start gap-2") do
                i(class: "fa-duotone fa-dice-d20 text-base text-purple-500 shrink-0 mt-0.5")
                div(class: "text-sm font-serif text-blue-900/80 font-medium text-left") do
                  pluralize(event.games.count, "table")
                end
              end

              # Seat availability (for upcoming events)
              if event.upcoming? && !is_cancelled && total_seats > 0
                div(class: "flex items-start gap-2 pt-2 border-t border-black/5") do
                  i(class: "fa-duotone fa-users text-base text-emerald-500 shrink-0 mt-0.5")
                  div(class: "text-sm font-serif text-left") do
                    if sold_out
                      span(class: "font-semibold text-rose-700") { "Sold Out" }
                    elsif available_seats < 5
                      span(class: "font-semibold text-rose-700") { "Only #{pluralize(available_seats, 'seat')} left!" }
                    else
                      span(class: "text-blue-900") { "#{pluralize(available_seats, 'seat')} available" }
                    end
                  end
                end
              end
            end

            # CTA Button
            if event.upcoming? && !is_cancelled && !sold_out
              link_to(event_path(event), class: "btn w-full") do
                "Get Tickets"
              end
            else
              link_to(event_path(event), class: "btn w-full bg-blue-900 hover:bg-blue-800") do
                "View Details"
              end
            end
          end
        end
      end
    end
  end

  def render_empty_state
    div(class: "text-center py-16 bg-white shadow-lg rounded-sm border border-black/10 max-w-lg mx-auto") do
      p(class: "font-serif text-blue-900 text-lg font-medium mb-2") { "No events scheduled at this time." }
      p(class: "font-serif text-blue-900/60 text-sm") { "Check back soon for upcoming events!" }
    end
  end

  def calculate_total_seats(event)
    event.games.sum(&:seat_count)
  end

  def calculate_available_seats(event)
    event.games.sum do |game|
      game.seat_count - game.seats.count { |seat| seat.user_id.present? }
    end
  end

  def pluralize(count, singular)
    "#{count} #{count == 1 ? singular : singular + 's'}"
  end
end

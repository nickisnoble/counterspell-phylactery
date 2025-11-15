# frozen_string_literal: true

class Views::Events::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(events:)
    @events = events
  end

  def view_template
    content_for(:title, "Events")

    main(class: "flex flex-col flex-1 justify-center items-center gap-8 px-4 py-8") do
      div(class: "text-center space-y-4 max-w-[36ch]") do
        h1(class: "font-display text-3xl mb-4") { "Upcoming Events" }
        p(class: "text-gray-600 text-pretty") do
          "Join us for an unforgettable adventure. Each event features multiple game tables led by experienced GMs."
        end
      end

      if @events.any?
        div(class: "grid gap-6 md:grid-cols-2 lg:grid-cols-3 max-w-6xl w-full") do
          @events.each do |event|
            render_event_card(event)
          end
        end
      else
        div(class: "text-center py-16 bg-white shadow rounded-lg border border-gray-200 max-w-lg") do
          p(class: "text-gray-600 text-lg font-medium mb-2") { "No events scheduled at this time." }
          p(class: "text-gray-500 text-sm") { "Check back soon for upcoming events!" }
        end
      end
    end
  end

  private

  def render_event_card(event)
    link_to(event_path(event), class: "block group") do
      div(class: "bg-white rounded-sm shadow border border-black/10 hover:shadow-lg transition-all overflow-hidden h-full") do
        div(class: "p-6 space-y-4") do
          div(class: "flex justify-between items-start gap-3") do
            h2(class: "font-bold text-xl text-gray-900 group-hover:text-blue-600 transition-colors") { event.name }
            span(class: "px-3 py-1 text-xs font-semibold rounded-full #{status_badge_class(event.status)} shrink-0") do
              event.status.titleize
            end
          end

          div(class: "space-y-3 text-sm text-gray-700") do
            div(class: "flex items-start") do
              span(class: "mr-3 text-lg shrink-0") { "📅" }
              div do
                div(class: "font-medium") { "Date" }
                div(class: "text-gray-600") { event.date.strftime("%A, %B %d, %Y") }
              end
            end

            if event.start_time
              div(class: "flex items-start") do
                span(class: "mr-3 text-lg shrink-0") { "🕐" }
                div do
                  div(class: "font-medium") { "Time" }
                  div(class: "text-gray-600") { "#{event.start_time.strftime('%I:%M %p')}#{event.end_time ? " - #{event.end_time.strftime('%I:%M %p')}" : ''}" }
                end
              end
            end

            div(class: "flex items-start") do
              span(class: "mr-3 text-lg shrink-0") { "📍" }
              div do
                div(class: "font-medium") { "Location" }
                div(class: "text-gray-600") { event.location.name }
              end
            end

            div(class: "flex items-start") do
              span(class: "mr-3 text-lg shrink-0") { "🎲" }
              div do
                div(class: "font-medium") { "Tables" }
                div(class: "text-gray-600") { pluralize(event.games.count, "table") }
              end
            end

            if event.ticket_price && event.ticket_price > 0
              div(class: "flex items-start") do
                span(class: "mr-3 text-lg shrink-0") { "💵" }
                div do
                  div(class: "font-medium") { "Price" }
                  div(class: "text-xl font-bold text-green-600") { "$#{event.ticket_price}" }
                end
              end
            end
          end
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

  def pluralize(count, singular)
    "#{count} #{count == 1 ? singular : singular + 's'}"
  end
end

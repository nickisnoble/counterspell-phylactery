# frozen_string_literal: true

class Views::Events::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(events:)
    @events = events
  end

  def view_template
    content_for(:title, "Events")

    main(class: "w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      div(class: "flex justify-between items-center mb-8") do
        h1(class: "font-bold text-4xl") { "Upcoming Events" }
      end

      if @events.any?
        div(class: "grid gap-6 md:grid-cols-2 lg:grid-cols-3") do
          @events.each do |event|
            render_event_card(event)
          end
        end
      else
        div(class: "text-center py-16 bg-gray-50 rounded-lg") do
          p(class: "text-gray-500 text-lg") { "No events scheduled at this time." }
          p(class: "text-gray-400 text-sm mt-2") { "Check back soon for upcoming events!" }
        end
      end
    end
  end

  private

  def render_event_card(event)
    link_to(event_path(event), class: "block") do
      div(class: "bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow overflow-hidden") do
        div(class: "p-6") do
          div(class: "flex justify-between items-start mb-4") do
            h2(class: "font-bold text-2xl text-gray-900") { event.name }
            span(class: "px-3 py-1 text-xs font-semibold rounded-full #{status_badge_class(event.status)}") do
              event.status.titleize
            end
          end

          div(class: "space-y-2 text-sm text-gray-600") do
            div(class: "flex items-center") do
              span(class: "mr-2") { "📅" }
              span { event.date.strftime("%A, %B %d, %Y") }
            end

            if event.start_time
              div(class: "flex items-center") do
                span(class: "mr-2") { "🕐" }
                span { "#{event.start_time.strftime('%I:%M %p')}#{event.end_time ? " - #{event.end_time.strftime('%I:%M %p')}" : ''}" }
              end
            end

            div(class: "flex items-center") do
              span(class: "mr-2") { "📍" }
              span { event.location.name }
            end

            div(class: "flex items-center") do
              span(class: "mr-2") { "🎲" }
              span { pluralize(event.games.count, "table") }
            end

            if event.ticket_price && event.ticket_price > 0
              div(class: "flex items-center font-semibold text-green-600") do
                span(class: "mr-2") { "💵" }
                span { "$#{event.ticket_price}" }
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

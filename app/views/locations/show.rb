# frozen_string_literal: true

class Views::Locations::Show < Views::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ContentFor

  def initialize(location:, upcoming_events:, past_events:)
    @location = location
    @upcoming_events = upcoming_events
    @past_events = past_events
  end

  def view_template
    content_for(:title, @location.name)

    main(class: "w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      # Back link
      div(class: "mb-6") do
        link_to("← Back to Venues", locations_path, class: "text-blue-600 hover:text-blue-800")
      end

      # Location header
      div(class: "bg-white rounded-lg shadow-md p-8 mb-6") do
        div(class: "flex items-start mb-4") do
          span(class: "text-4xl mr-4") { "📍" }
          h1(class: "font-bold text-4xl text-gray-900") { @location.name }
        end

        if @location.address.present?
          div(class: "ml-16") do
            p(class: "text-gray-700 text-lg") { @location.address }
          end
        end

        if @location.about.present?
          div(class: "mt-6 ml-16 prose max-w-none") do
            render @location.about
          end
        end
      end

      # Upcoming events
      if @upcoming_events.any?
        div(class: "bg-white rounded-lg shadow-md p-8 mb-6") do
          h2(class: "font-bold text-2xl mb-6") { "Upcoming Events" }
          div(class: "space-y-4") do
            @upcoming_events.each do |event|
              render_event_card(event)
            end
          end
        end
      end

      # Past events
      if @past_events.any?
        div(class: "bg-white rounded-lg shadow-md p-8") do
          h2(class: "font-bold text-2xl mb-6") { "Past Events" }
          div(class: "space-y-4") do
            @past_events.each do |event|
              render_event_card(event)
            end
          end
        end
      end

      # No events message
      if @upcoming_events.empty? && @past_events.empty?
        div(class: "bg-yellow-50 rounded-lg p-6 text-center") do
          p(class: "text-yellow-800") { "No events scheduled at this venue yet." }
        end
      end
    end
  end

  private

  def render_event_card(event)
    link_to(event_path(event), class: "block") do
      div(class: "border border-gray-200 rounded-lg p-4 hover:border-blue-400 hover:shadow transition") do
        div(class: "flex justify-between items-start") do
          div do
            h3(class: "font-semibold text-lg text-gray-900") { event.name }
            p(class: "text-gray-600 text-sm mt-1") do
              event.date.strftime("%A, %B %d, %Y")
            end
            if event.start_time
              p(class: "text-gray-500 text-sm") do
                event.start_time.strftime("%I:%M %p")
              end
            end
          end

          span(class: "px-3 py-1 text-xs font-semibold rounded-full #{status_class(event.status)}") do
            event.status.titleize
          end
        end

        if event.games.any?
          p(class: "text-sm text-gray-500 mt-2") do
            "#{event.games.count} #{'table'.pluralize(event.games.count)} available"
          end
        end
      end
    end
  end

  def status_class(status)
    case status
    when "upcoming"
      "bg-green-100 text-green-800"
    when "past"
      "bg-gray-100 text-gray-800"
    else
      "bg-yellow-100 text-yellow-800"
    end
  end
end

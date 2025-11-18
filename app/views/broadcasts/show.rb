# frozen_string_literal: true

class Views::Broadcasts::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(broadcast:)
    @broadcast = broadcast
  end

  def view_template
    content_for(:title, @broadcast.subject)

    main(class: "w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      if @broadcast.event.present?
        div(class: "mb-6") do
          link_to("← Back to Event", event_path(@broadcast.event), class: "text-blue-600 hover:text-blue-800")
        end
      end

      div(class: "bg-white rounded-lg shadow-md overflow-hidden") do
        div(class: "bg-gray-50 border-b border-gray-200 p-6") do
          h1(class: "font-bold text-3xl text-gray-900 mb-4") { @broadcast.subject }

          div(class: "space-y-2 text-sm text-gray-600") do
            if @broadcast.sent?
              div(class: "flex items-center text-green-600") do
                span(class: "mr-2") { "✓" }
                span(class: "font-semibold") { "Sent on #{@broadcast.sent_at.strftime("%B %d, %Y at %I:%M %p")}" }
              end
            end
          end
        end

        div(class: "p-8") do
          if @broadcast.body.present?
            div(class: "prose max-w-none") do
              render @broadcast.body
            end
          end
        end

        if @broadcast.event.present?
          div(class: "bg-gray-50 border-t border-gray-200 p-6") do
            h2(class: "font-bold text-lg mb-3") { "Event Details" }
            div(class: "text-sm text-gray-700 space-y-1") do
              div { "📅 #{@broadcast.event.date.strftime('%A, %B %d, %Y')}" }
              if @broadcast.event.start_time
                div { "🕐 #{@broadcast.event.start_time.strftime('%I:%M %p')}#{@broadcast.event.end_time ? " - #{@broadcast.event.end_time.strftime('%I:%M %p')}" : ''}" }
              end
              div { "📍 #{@broadcast.event.location.name}" }
            end
          end
        end
      end
    end
  end
end

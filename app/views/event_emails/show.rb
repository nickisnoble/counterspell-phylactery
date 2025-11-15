# frozen_string_literal: true

class Views::EventEmails::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(event:, event_email:)
    @event = event
    @event_email = event_email
  end

  def view_template
    content_for(:title, @event_email.subject)

    main(class: "w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      # Back link
      div(class: "mb-6") do
        link_to("← Back to Event", event_path(@event), class: "text-blue-600 hover:text-blue-800")
      end

      # Email container (styled like an email)
      div(class: "bg-white rounded-lg shadow-md overflow-hidden") do
        # Email header
        div(class: "bg-gray-50 border-b border-gray-200 p-6") do
          h1(class: "font-bold text-3xl text-gray-900 mb-4") { @event_email.subject }

          div(class: "space-y-2 text-sm text-gray-600") do
            div do
              span(class: "font-semibold") { "Event: " }
              link_to(@event.name, event_path(@event), class: "text-blue-600 hover:text-blue-800")
            end

            div do
              span(class: "font-semibold") { "Scheduled to send: " }
              span { @event_email.send_at.strftime("%B %d, %Y at %I:%M %p") }
            end

            if @event_email.sent?
              div(class: "flex items-center text-green-600") do
                span(class: "mr-2") { "✓" }
                span(class: "font-semibold") { "Sent on #{@event_email.sent_at.strftime("%B %d, %Y at %I:%M %p")}" }
              end
            else
              div(class: "flex items-center text-yellow-600") do
                span(class: "mr-2") { "⏰" }
                span(class: "font-semibold") { "Not yet sent" }
              end
            end
          end
        end

        # Email body
        div(class: "p-8") do
          if @event_email.body.present?
            div(class: "prose max-w-none") do
              render @event_email.body
            end
          else
            div(class: "text-gray-500 italic text-center py-8") do
              p { "This email reminder has no additional message." }
              p(class: "text-sm mt-2") { "Recipients will receive event details with this subject line." }
            end
          end
        end

        # Event details footer
        div(class: "bg-gray-50 border-t border-gray-200 p-6") do
          h2(class: "font-bold text-lg mb-3") { "Event Details" }
          div(class: "text-sm text-gray-700 space-y-1") do
            div { "📅 #{@event.date.strftime('%A, %B %d, %Y')}" }
            if @event.start_time
              div { "🕐 #{@event.start_time.strftime('%I:%M %p')}#{@event.end_time ? " - #{@event.end_time.strftime('%I:%M %p')}" : ''}" }
            end
            div { "📍 #{@event.location.name}" }
          end
        end
      end
    end
  end
end

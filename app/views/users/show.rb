# frozen_string_literal: true

class Views::Users::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(user:, past_event_data: {})
    @user = user
    @past_event_data = past_event_data
  end

  def view_template
    content_for(:title, "Showing user")

    main do
      article(class: "bg-white rounded-xl max-w-screen-md shadow mx-auto p-6 space-y-6") do
        h2(class: "font-bold text-4xl") { @user.display_name }

        div(class: "text-left") do
          raw @user.bio.to_s
        end

        # Past Events Section
        if @past_event_data.any?
          div(class: "mt-8") do
            h3(class: "font-bold text-2xl mb-4") { "Past Events" }

            div(class: "space-y-4") do
              @past_event_data.each do |event, seats|
                div(class: "border border-gray-200 rounded-lg p-4") do
                  div(class: "flex justify-between items-start") do
                    div do
                      h4(class: "font-semibold text-lg") do
                        link_to(event.name, event_path(event), class: "text-blue-600 hover:text-blue-800")
                      end
                      p(class: "text-sm text-gray-600") do
                        "#{event.date.strftime('%B %d, %Y')} at #{event.location.name}"
                      end
                    end
                  end

                  div(class: "mt-3") do
                    seats.each do |seat|
                      div(class: "flex items-center text-sm text-gray-700") do
                        span(class: "mr-2") { "🎭" }
                        span { "Played #{seat.hero&.name || 'Unknown Hero'}" }
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

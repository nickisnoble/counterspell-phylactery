# frozen_string_literal: true

class Views::Newsletters::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor

  def initialize(newsletter:)
    @newsletter = newsletter
  end

  def view_template
    content_for(:title, @newsletter.subject)

    main(class: "w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      div(class: "bg-white rounded-lg shadow-md overflow-hidden") do
        div(class: "bg-gray-50 border-b border-gray-200 p-6") do
          h1(class: "font-bold text-3xl text-gray-900 mb-4") { @newsletter.subject }

          div(class: "space-y-2 text-sm text-gray-600") do
            if @newsletter.sent?
              div(class: "flex items-center text-green-600") do
                span(class: "mr-2") { "✓" }
                span(class: "font-semibold") { "Sent on #{@newsletter.sent_at.strftime("%B %d, %Y at %I:%M %p")}" }
              end
            end
          end
        end

        div(class: "p-8") do
          if @newsletter.body.present?
            div(class: "prose max-w-none") do
              render @newsletter.body
            end
          end
        end
      end
    end
  end
end

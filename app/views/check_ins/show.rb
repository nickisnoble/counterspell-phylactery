# frozen_string_literal: true

class Views::CheckIns::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo

  def view_template
    content_for(:title, "QR Code Check-in")

    main(class: "w-full max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      div(class: "bg-white rounded-lg shadow-md p-8") do
        h1(class: "font-bold text-3xl mb-6") { "Event Check-in" }

        p(class: "text-gray-600 mb-8") do
          "Scan a ticket's QR code to check in attendees."
        end

        # Manual token entry form
        div(class: "border-2 border-gray-200 rounded-lg p-6") do
          h2(class: "font-bold text-xl mb-4") { "Manual Token Entry" }
          p(class: "text-sm text-gray-600 mb-4") do
            "Enter the ticket token manually if you can't scan the QR code."
          end

          form_with(url: check_in_path, method: :post, class: "space-y-4") do |f|
            div do
              f.label :token, "Ticket Token", class: "block font-medium mb-2"
              f.text_field :token,
                required: true,
                placeholder: "Enter 32-character token",
                class: "block w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent font-mono"
            end

            div do
              f.submit "Check In",
                class: "w-full px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white font-medium rounded-md transition cursor-pointer"
            end
          end
        end

        # Info section
        div(class: "mt-8 p-4 bg-blue-50 rounded-lg") do
          h3(class: "font-semibold text-blue-900 mb-2") { "ℹ️ How to use" }
          ul(class: "text-sm text-blue-800 space-y-1 list-disc list-inside") do
            li { "Ask the attendee to show their ticket" }
            li { "Scan the QR code or enter the token manually" }
            li { "The system will confirm check-in" }
          end
        end

        # Back link
        div(class: "mt-6") do
          link_to("← Back to Events", events_path,
            class: "text-blue-600 hover:text-blue-800")
        end
      end
    end
  end
end

# frozen_string_literal: true

class Views::Admin::Events::Edit < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(event:, locations:)
    @event = event
    @locations = locations
  end

  def view_template
    content_for(:title, "Editing event")

    div(class: "md:w-2/3 w-full mx-auto") do
      h1(class: "font-bold text-4xl mb-6") { "Editing event" }

      render Views::Admin::Events::Form.new(event: @event, locations: @locations)

      div(class: "mt-4") do
        link_to("Back to events", admin_events_path, class: "rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium")
      end
    end
  end
end

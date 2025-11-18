# frozen_string_literal: true

class Views::Dashboard::Broadcasts::New < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(broadcast:, events:)
    @broadcast = broadcast
    @events = events
  end

  def view_template
    content_for(:title, "New Broadcast")

    div(class: "md:w-2/3 w-full mx-auto") do
      h1(class: "font-bold text-4xl mb-6") { "New Broadcast" }

      render Views::Dashboard::Broadcasts::Form.new(broadcast: @broadcast, events: @events)

      link_to("Back to broadcasts", dashboard_broadcasts_path, class: "w-full sm:w-auto text-center mt-4 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium")
    end
  end
end

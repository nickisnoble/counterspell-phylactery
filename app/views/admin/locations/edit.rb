# frozen_string_literal: true

class Views::Admin::Locations::Edit < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(location:)
    @location = location
  end

  def view_template
    content_for(:title, "Editing location")

    div(class: "md:w-2/3 w-full mx-auto") do
      h1(class: "font-bold text-4xl mb-6") { "Editing location" }

      render Views::Admin::Locations::Form.new(location: @location)

      div(class: "mt-4") do
        link_to("Back to locations", admin_locations_path, class: "rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium")
      end
    end
  end
end

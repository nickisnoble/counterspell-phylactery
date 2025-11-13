# frozen_string_literal: true

class Views::Admin::Locations::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(location:)
    @location = location
  end

  def view_template
    form_with(model: @location, url: @location.persisted? ? admin_location_path(@location) : admin_locations_path, class: "contents text-left") do |form|
      if @location.errors.any?
        div(id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3") do
          h2 { "#{pluralize(@location.errors.count, 'error')} prohibited this location from being saved:" }

          ul(class: "list-disc ml-6") do
            @location.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "my-5") do
        form.label :name
        form.text_field :name, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "my-5") do
        form.label :address
        form.text_area :address, rows: 3, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div(class: "my-5") do
        form.label :about
        form.rich_text_area :about, class: "block shadow rounded-md border border-gray-200 outline-none px-3 py-2 mt-2 w-full"
      end

      div do
        form.submit class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-medium cursor-pointer"
      end
    end
  end
end

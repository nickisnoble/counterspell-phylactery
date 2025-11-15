# frozen_string_literal: true

class Views::Dashboard::Locations::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(location:)
    @location = location
  end

  def view_template
    form_with(model: @location, url: @location.persisted? ? dashboard_location_path(@location) : dashboard_locations_path, class: "max-w-2xl") do |form|
      if @location.errors.any?
        div(id: "error_explanation", class: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-6") do
          h2(class: "font-semibold mb-2") { "#{pluralize(@location.errors.count, 'error')} prohibited this location from being saved:" }
          ul(class: "list-disc ml-5 text-sm space-y-1") do
            @location.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
        h3(class: "font-semibold text-lg mb-6 pb-3 border-b border-gray-200") { "Location Details" }

        div(class: "space-y-5") do
          div do
            form.label :name, class: "block text-sm font-medium text-gray-700 mb-2"
            form.text_field :name, class: input_classes, placeholder: "e.g., The Game Haven"
          end

          div do
            form.label :address, class: "block text-sm font-medium text-gray-700 mb-2"
            form.text_area :address, rows: 3, class: input_classes, placeholder: "123 Main St, City, State"
          end

          div do
            form.label :about, "About", class: "block text-sm font-medium text-gray-700 mb-2"
            form.rich_text_area :about, class: "block w-full rounded-md border border-gray-200"
          end
        end
      end

      div do
        form.submit class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-md cursor-pointer transition"
      end
    end
  end

  private

  def input_classes
    "block w-full rounded-md border border-gray-300 px-3 py-2.5 text-gray-900 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition"
  end
end

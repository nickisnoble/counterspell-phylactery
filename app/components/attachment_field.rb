# frozen_string_literal: true

class Components::AttachmentField < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  def initialize(form:, attribute:, label: nil, current_file: nil, preview_classes: "w-full h-64 object-cover bg-stone-100")
    @form = form
    @attribute = attribute
    @label = label || attribute.to_s.humanize
    @current_file = current_file
    @preview_classes = preview_classes
  end

  def view_template
    div(class: "space-y-2") do
      label(for: "#{@form.object_name}_#{@attribute}", class: "block font-medium") { @label }

      if @current_file&.attached?
        div(class: "mb-2") do
          figure(class: @preview_classes) do
            img(src: url_for(@current_file), alt: @label, class: "w-full h-full object-cover")
          end
        end
      end

      @form.file_field(@attribute, class: "block w-full text-sm file:mr-4 file:py-2 file:px-4 file:rounded file:border-0 file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100")
    end
  end
end

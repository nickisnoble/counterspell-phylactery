# frozen_string_literal: true

class Views::Pages::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(page:)
    @page = page
  end

  def view_template
    form_with(model: @page, class: "contents text-left") do |form|
      if @page.errors.any?
        div(id: "error_explanation", class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3") do
          h2 { "#{pluralize(@page.errors.count, 'error')} prohibited this page from being saved:" }

          ul(class: "list-disc ml-6") do
            @page.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "my-5") do
        form.label :title
        form.text_field :title
      end

      div(class: "my-5") do
        form.label :body
        form.rich_textarea :body
      end

      div(class: "inline") do
        form.submit class: "btn"
      end
    end
  end
end

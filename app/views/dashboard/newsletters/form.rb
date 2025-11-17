# frozen_string_literal: true

class Views::Dashboard::Newsletters::Form < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(newsletter:)
    @newsletter = newsletter
  end

  def view_template
    form_with(model: @newsletter, url: @newsletter.persisted? ? dashboard_newsletter_path(@newsletter) : dashboard_newsletters_path, class: "max-w-3xl") do |form|
      if @newsletter.errors.any?
        div(id: "error_explanation", class: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-6") do
          h2(class: "font-semibold mb-2") { "#{pluralize(@newsletter.errors.count, 'error')} prohibited this newsletter from being saved:" }
          ul(class: "list-disc ml-5 text-sm space-y-1") do
            @newsletter.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end

      div(class: "bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6") do
        div(class: "space-y-5") do
          div do
            form.label :subject, class: "block text-sm font-medium text-gray-700 mb-2"
            form.text_field :subject, class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500", placeholder: "Newsletter subject line"
          end

          div do
            form.label :body, class: "block text-sm font-medium text-gray-700 mb-2"
            form.rich_text_area :body, class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          end

          div do
            form.label :scheduled_at, "Scheduled to send at", class: "block text-sm font-medium text-gray-700 mb-2"
            form.datetime_field :scheduled_at, class: "w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          end

          div do
            form.label :draft, class: "flex items-center gap-2"
            form.check_box :draft, class: "rounded border-gray-300 text-blue-600 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            span(class: "text-sm text-gray-700") { "Save as draft (will not send automatically)" }
          end
        end
      end

      div(class: "flex gap-4") do
        form.submit "Save Newsletter", class: "px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md text-sm font-medium transition"
      end
    end
  end
end

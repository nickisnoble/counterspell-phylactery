# frozen_string_literal: true

class Views::Pages::Index < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(pages:)
    @pages = pages
  end

  def view_template
    content_for(:title, "Pages")

    div(class: "w-full") do
      div(class: "flex justify-between items-center") do
        h1(class: "font-bold text-4xl") { "Pages" }
        link_to("New page", new_page_path, class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium")
      end

      div(id: "pages", class: "min-w-full divide-y divide-gray-200 space-y-5") do
        if @pages.any?
          @pages.each do |page|
            div(class: "flex flex-col sm:flex-row justify-between items-center pb-5 sm:pb-0") do
              render Views::Pages::Page.new(page: page)
              div(class: "w-full sm:w-auto flex flex-col sm:flex-row space-x-2 space-y-2") do
                link_to("Show", page, class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium")
                link_to("Edit", edit_page_path(page), class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium")
                button_to("Destroy", page, method: :delete, class: "w-full sm:w-auto rounded-md px-3.5 py-2.5 text-white bg-red-600 hover:bg-red-500 font-medium cursor-pointer", data: { turbo_confirm: "Are you sure?" })
              end
            end
          end
        else
          p(class: "text-center my-10") { "No pages found." }
        end
      end
    end
  end
end

# frozen_string_literal: true

class Views::Dashboard::Newsletters::Edit < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(newsletter:)
    @newsletter = newsletter
  end

  def view_template
    content_for(:title, "Edit Newsletter")

    div(class: "md:w-2/3 w-full mx-auto") do
      h1(class: "font-bold text-4xl mb-6") { "Edit Newsletter" }

      render Views::Dashboard::Newsletters::Form.new(newsletter: @newsletter)

      link_to("Back to newsletters", dashboard_newsletters_path, class: "w-full sm:w-auto text-center mt-4 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium")
    end
  end
end

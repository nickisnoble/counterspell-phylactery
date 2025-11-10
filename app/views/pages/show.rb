# frozen_string_literal: true

class Views::Pages::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor

  def initialize(page:)
    @page = page
  end

  def view_template
    content_for(:title, "Showing page")

    main(class: "md:w-2/3 w-full mx-auto") do
      render Views::Pages::Page.new(page: @page)
    end
  end
end

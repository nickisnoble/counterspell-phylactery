# frozen_string_literal: true

class Views::Pages::FormFrame < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    turbo_frame_tag :page_form do
      render Views::Pages::FormComponent.new(page: @page)
    end
  end
end

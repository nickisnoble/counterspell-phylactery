# frozen_string_literal: true

class Views::Pages::Page < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    article(id: dom_id(@page), class: "w-full sm:w-auto space-y-6") do
      h1(class: "font-bold text-4xl") { @page.title }
      div(class: "text-left") do
        raw @page.body.to_s
      end
    end
  end
end

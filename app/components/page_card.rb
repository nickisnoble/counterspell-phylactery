class Components::PageCard < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    # Cache the page card - busts automatically when page is updated
    cache(@page) do
      article(id: dom_id(@page), class: "w-full sm:w-auto space-y-6") do
        h1(class: "font-bold text-4xl") { @page.title }
        div(class: "text-left") do
          raw @page.body.to_s
        end
      end
    end
  end
end

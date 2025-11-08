class Views::Pages::Show < Views::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    content_for :title, "Showing page"

    main class: "md:w-2/3 w-full mx-auto" do
      PageCard(page: @page)
    end
  end
end

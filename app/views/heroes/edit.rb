class Views::Heroes::Edit < Views::Base
  def initialize(hero:)
    @hero = hero
  end

  def view_template
    content_for :title, "Editing hero"

    main class: "md:w-2/3 w-full mx-auto" do
      h1(class: "font-bold text-4xl") { "Editing hero" }

      render Heroes::FormComponent.new(hero: @hero)

      link_to "Show this hero", @hero, class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      link_to "Back to heroes", heroes_path, class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
    end
  end
end

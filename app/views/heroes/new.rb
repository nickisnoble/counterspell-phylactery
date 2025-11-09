class Views::Heroes::New < Views::Base
  def initialize(hero:)
    @hero = hero
  end

  def view_template
    content_for :title, "New hero"

    main class: "md:w-2/3 w-full mx-auto" do
      h1(class: "font-bold text-4xl") { "New hero" }

      turbo_frame_tag :hero_form do
        render Views::Heroes::FormComponent.new(hero: @hero)
      end

      link_to "Back to heroes", heroes_path, class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
    end
  end
end

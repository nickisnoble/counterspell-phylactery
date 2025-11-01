class Traits::New < ApplicationComponent
  def initialize(trait:)
    @trait = trait
  end

  def view_template
    content_for :title, "New trait"

    div class: "md:w-2/3 w-full mx-auto" do
      h1(class: "font-bold text-4xl") { "New trait" }

      render Traits::FormComponent.new(trait: @trait)

      link_to "Back to traits", traits_path, class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
    end
  end
end

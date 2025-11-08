class Views::Traits::Show < Views::Base
  def initialize(trait:, current_user:)
    @trait = trait
    @current_user = current_user
  end

  def view_template
    content_for :title, @trait.name

    main class: "flex justify-center items-center" do
      div class: "max-w-[3in]" do
        nav class: "flex gap-2 px-2 py-1 opacity-50" do
          raw link_to("&larr; back to traits", traits_path)
          link_to "Edit", edit_trait_path(@trait) if @current_user.admin?
        end

        render Components::TraitCard.new(trait: @trait)
      end
    end
  end
end

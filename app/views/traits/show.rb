# frozen_string_literal: true

class Views::Traits::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo

  def initialize(trait:)
    @trait = trait
  end

  def view_template
    content_for(:title, @trait.name)

    main(class: "flex justify-center items-center") do
      div(class: "max-w-[3in]") do
        nav(class: "flex gap-2 px-2 py-1 opacity-50") do
          raw link_to("&larr; back to traits", traits_path)
          link_to("Edit", edit_trait_path(@trait)) if Current.user.admin?
        end

        render Components::Card.from_trait(@trait)
      end
    end
  end
end

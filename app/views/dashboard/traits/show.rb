# frozen_string_literal: true

class Views::Dashboard::Traits::Show < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::URLFor
  include ActionView::RecordIdentifier

  def initialize(trait:)
    @trait = trait
  end

  def view_template
    content_for(:title, @trait.name)

    main(class: "flex justify-center items-center") do
      div(class: "max-w-[3in]") do
        nav(class: "flex gap-2 px-2 py-1 opacity-50") do
          raw link_to("&larr; back to traits", dashboard_traits_path)
          link_to("Edit", edit_dashboard_trait_path(@trait)) if Current.user.admin?
        end

        cover_url = @trait.cover.attached? ? url_for(@trait.cover) : nil
        render Components::Card.new(
          title: @trait.name,
          cover: cover_url,
          dom_id: dom_id(@trait),
          badge: @trait.type
        ) do
          p(class: "font-light italic text-pretty leading-snug") { @trait.description }

          if @trait.abilities.present? && @trait.abilities.any?
            ul(class: "space-y-2 text-xs") do
              @trait.abilities.each do |name, description|
                li do
                  strong(class: "font-black text-[0.8em] uppercase") { "#{name}:" }
                  whitespace
                  plain description
                end
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Components::Card < Components::Base
  include Phlex::Rails::Helpers::URLFor

  def initialize(
    title:,
    subtitle: nil,
    description: nil,
    cover_image: nil,
    abilities: {},
    dom_id: nil,
    badge: nil
  )
    @title = title
    @subtitle = subtitle
    @description = description
    @cover_image = cover_image
    @abilities = abilities
    @dom_id = dom_id
    @badge = badge
  end

  def view_template
    article(
      id: @dom_id,
      class: "flex flex-col bg-white shadow border-black/20 rounded-2xl w-full max-w-[3in] aspect-[4/6] overflow-clip [corner-shape:squircle]"
    ) do
      header(class: "flex flex-col flex-[2] justify-end bg-stone-200 bg-cover bg-center") do
        div(class: "flex max-sm:flex-col justify-between items-start md:items-end px-3 py-1") do
          h3(class: "font-semibold text-2xl text-left text-balance") { @title }
          if @badge
            p(class: "inline-block max-sm:-order-1 bg-yellow-500 my-1 px-1 py-px rounded font-bold text-xs") do
              @badge
            end
          end
        end
      end

      div(class: "flex flex-col flex-[3] gap-4 p-3 text-sm text-left") do
        if @subtitle
          p(class: "text-stone-500 text-xs") { @subtitle }
        end

        if @description
          p(class: "font-light italic text-pretty leading-snug") { @description }
        end

        if @abilities.present? && @abilities.any?
          ul(class: "space-y-2 text-xs") do
            @abilities.each do |name, description|
              li do
                strong(class: "font-black text-[0.8em] uppercase") { "#{name}:" }
                whitespace
                plain description
              end
            end
          end
        end
      end

      if @cover_image
        style do
          unsafe_raw "##{@dom_id} header { background-image: url(#{@cover_image}); }"
        end
      end
    end
  end

  # Convenience class methods for creating cards from models
  class << self
    def from_trait(trait)
      new(
        title: trait.name,
        description: trait.description,
        cover_image: trait.cover.attached? ? Phlex::Rails.helpers.url_for(trait.cover) : nil,
        abilities: trait.abilities || {},
        dom_id: Phlex::Rails.helpers.dom_id(trait),
        badge: trait.type
      )
    end

    def from_hero(hero)
      new(
        title: hero.name,
        subtitle: "#{hero.pronouns} • #{hero.role.humanize}",
        description: hero.summary&.to_plain_text,
        cover_image: hero.portrait.attached? ? Phlex::Rails.helpers.url_for(hero.portrait) : nil,
        abilities: hero.traits.map { |t| [t.name, t.type] }.to_h,
        dom_id: Phlex::Rails.helpers.dom_id(hero)
      )
    end
  end
end

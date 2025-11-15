# frozen_string_literal: true

class Components::Card < Components::Base
  def initialize(
    title:,
    cover: nil,
    dom_id: nil,
    badge: nil
  )
    @title = title
    @cover = cover
    @dom_id = dom_id
    @badge = badge
  end

  def view_template(&block)
    # Trading card aspect ratio: 63:88 (2.48" x 3.46")
    # Display at 3x physical size for screens: ~189mm width
    article(
      id: @dom_id,
      class: "flex flex-col bg-white shadow-lg border border-black/10 rounded-lg w-full max-w-[189mm] aspect-[63/88] overflow-hidden"
    ) do
      # Header takes ~40% of card height
      header(class: "flex flex-col flex-[2] justify-end bg-gradient-to-br from-purple-600 to-pink-600 bg-cover bg-center p-4") do
        div(class: "flex justify-between items-end gap-2") do
          h3(class: "font-bold text-2xl text-white text-left drop-shadow-lg") { @title }
          if @badge
            p(class: "bg-yellow-400 text-black px-2 py-1 rounded font-bold text-sm uppercase whitespace-nowrap") do
              @badge
            end
          end
        end
      end

      # Body takes ~60% of card height
      div(class: "flex flex-col flex-[3] gap-3 p-4 text-sm text-left") do
        yield if block_given?
      end

      if @cover
        style do
          plain "##{@dom_id} header { background-image: url(#{@cover}); }"
        end
      end
    end
  end
end

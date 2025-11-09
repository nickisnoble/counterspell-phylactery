class Components::TraitCard < Views::Base
  def initialize(trait:)
    @trait = trait
  end

  def view_template
    # Cache the entire card using the trait record and its updated_at timestamp
    # Cache automatically includes: deployment timestamp, class name, method, line number
    cache(@trait) do
      article(
        id: dom_id(@trait),
        class: "flex flex-col bg-white shadow border-black/20 rounded-2xl w-full max-w-[3in] aspect-[4/6] overflow-clip [corner-shape:squircle]"
      ) do
        header(class: "flex flex-col flex-[2] justify-end bg-stone-200 bg-cover bg-center") do
          div(class: "flex max-sm:flex-col justify-between items-start md:items-end px-3 py-1") do
            h3(class: "font-semibold text-2xl text-left text-balance") { @trait.name }
            p(class: "inline-block max-sm:-order-1 bg-yellow-500 my-1 px-1 py-px rounded font-bold text-xs") { @trait.type }
          end
        end

        div(class: "flex flex-col flex-[3] gap-4 p-3 text-sm text-left") do
          p(class: "font-light italic text-pretty leading-snug") { @trait.description }

          if @trait.abilities.present? && @trait.abilities.any?
            ul(class: "space-y-2 text-xs") do
              @trait.abilities.each do |name, description|
                li do
                  strong(class: "font-black text-[0.8em] uppercase") { "#{name}:" }
                  plain " #{description}"
                end
              end
            end
          end
        end

        # Inline style for cover image background
        if @trait.cover.attached?
          style do
            raw safe("##{dom_id(@trait)} header { background-image: url(#{url_for(@trait.cover)}); }")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

class Views::Seats::New < Views::Base
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::URLFor

  def initialize(event:, game:, available_heroes:)
    @event = event
    @game = game
    @available_heroes = available_heroes
  end

  def view_template
    content_for(:title, "Purchase Seat - #{@event.name}")

    main(class: "w-full max-w-4xl mx-auto px-4 py-12 bg-amber-50 min-h-screen") do
      # Back link
      div(class: "mb-8") do
        link_to("← Back to Event", event_path(@event), class: "font-serif text-purple-900 hover:text-purple-700 font-medium transition")
      end

      # Hero selection form
      if @available_heroes.any?
        render_wizard_form
      else
        div(class: "py-12 text-center") do
          p(class: "font-serif text-lg text-blue-900/60 mb-6") { "All heroes are already taken at this table." }
          link_to("← Back to Event", event_path(@event), class: "btn px-6 py-3 font-serif font-semibold")
        end
      end
    end
  end

  private

  def render_wizard_form
    form_with(
      url: event_game_seats_path(@event, @game),
      method: :post,
      data: { controller: "wizard" },
      class: "space-y-6"
    ) do |f|
      # Step 1: Hero Selection
      div(data: { wizard_target: "step" }) do
        div(class: "mb-8") do
          h1(class: "font-display text-4xl text-blue-900 mb-2") { "Choose Your Hero" }
          p(class: "font-serif text-lg text-blue-900/80") do
            "GM: #{@game.gm.display_name}"
          end
        end

        div(class: "grid grid-cols-1 sm:grid-cols-2 gap-4") do
          @available_heroes.each do |hero|
            render_hero_option(hero)
          end
        end
      end

      # Step 2: Review Order
      div(data: { wizard_target: "step" }, class: "hidden") do
        div(class: "mb-8") do
          h1(class: "font-display text-4xl text-blue-900 mb-2") { "Review Your Order" }
        end

        div(class: "bg-white/50 rounded-sm border border-black/10 p-6 space-y-4") do
          # Event details
          div(class: "border-b border-black/10 pb-4") do
            p(class: "font-serif text-sm text-blue-900/60 mb-1") { "Event" }
            p(class: "font-display text-xl text-blue-900") { @event.name }
            p(class: "font-serif text-blue-900/80") do
              if @event.start_time
                "#{@event.date.strftime('%B %d, %Y')} at #{@event.start_time.strftime('%I:%M %p')}"
              else
                @event.date.strftime('%B %d, %Y')
              end
            end
          end

          # GM details
          div(class: "border-b border-black/10 pb-4") do
            p(class: "font-serif text-sm text-blue-900/60 mb-1") { "Game Master" }
            p(class: "font-display text-lg text-blue-900") { @game.gm.display_name }
          end

          # Hero selection (will be updated by JavaScript)
          div(class: "border-b border-black/10 pb-4", id: "selected-hero-display") do
            p(class: "font-serif text-sm text-blue-900/60 mb-1") { "Your Hero" }
            p(class: "font-display text-lg text-blue-900", data: { hero_name: "hero-name-display" }) { "No hero selected" }
          end

          # Price
          div do
            p(class: "font-serif text-sm text-blue-900/60 mb-1") { "Ticket Price" }
            p(class: "font-display text-2xl text-purple-900") { "$#{@event.ticket_price}" }
          end
        end
      end

      # Navigation buttons
      div(class: "pt-6 border-t border-black/10 flex gap-4 justify-between") do
        # Previous button
        button(
          type: "button",
          data: { action: "click->wizard#previous", wizard_target: "prevButton" },
          class: "btn-secondary px-6 py-3 font-serif font-semibold hidden"
        ) { "← Previous" }

        div(class: "flex-1")

        # Next button
        button(
          type: "button",
          data: { action: "click->wizard#next", wizard_target: "nextButton" },
          class: "btn px-6 py-3 font-serif font-semibold"
        ) { "Continue →" }

        # Submit button (hidden initially)
        f.submit "Continue to Checkout",
          data: { wizard_target: "submitButton" },
          class: "btn block px-6 py-3 text-center font-serif font-semibold cursor-pointer hidden"
      end
    end
  end

  def render_hero_option(hero)
    label_class = "relative flex flex-col cursor-pointer rounded-sm border border-black/10 p-3 transition hover:border-purple-500 hover:bg-white bg-white/50"

    label(class: label_class) do
      input(
        type: "radio",
        name: "hero_id",
        value: hero.id,
        class: "peer sr-only",
        required: true
      )

      # Selected indicator
      div(class: "absolute top-3 right-3 hidden peer-checked:block") do
        div(class: "w-6 h-6 bg-purple-900 rounded-full flex items-center justify-center") do
          i(class: "fa-solid fa-check text-white text-xs")
        end
      end

      # Hero portrait
      if hero.portrait.present?
        div(class: "aspect-square w-full mb-3 rounded-sm overflow-hidden bg-amber-100 border border-black/10") do
          image_tag(url_for(hero.portrait), class: "w-full h-full object-cover object-top")
        end
      else
        div(class: "aspect-square w-full mb-3 rounded-sm bg-amber-100 border border-black/10 flex items-center justify-center") do
          i(class: "fa-duotone fa-mask text-4xl text-purple-500")
        end
      end

      # Hero info
      p(class: "font-serif font-semibold text-sm text-blue-900 mb-1") { hero.name }
      p(class: "font-serif text-xs text-blue-900/60") do
        plain "#{hero.pronouns}"
        if hero.role
          plain " • #{hero.role.humanize}"
        end
      end
    end
  end
end

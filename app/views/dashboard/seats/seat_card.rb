# frozen_string_literal: true

class Views::Dashboard::Seats::SeatCard < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(seat:, event:, show_errors: false)
    @seat = seat
    @event = event
    @show_errors = show_errors
    @has_errors = seat.errors.any?
  end

  def view_template
    turbo_frame_tag("seat_#{@seat.id}", class: "contents") do
      div(class: card_classes) do
        # Error message (if any)
        if @show_errors && @has_errors
          div(class: "mb-3 p-2 bg-red-100 border border-red-200 rounded text-sm text-red-800") do
            i(class: "fa-solid fa-exclamation-triangle mr-1")
            plain @seat.errors.full_messages.to_sentence
          end
        end

        # Player and Hero info
        div(class: "mb-3") do
          div(class: "font-medium text-sm text-gray-900 mb-1") do
            plain @seat.user.display_name
            if @seat.hero
              plain " • "
              span(class: "text-gray-600 font-normal") { @seat.hero.name }
            end
          end
          if @seat.user.email.present?
            div(class: "text-xs text-gray-500") { @seat.user.email }
          end
        end

        # Reassignment form
        form_with(
          model: @seat,
          url: dashboard_event_seat_path(@event, @seat),
          method: :patch,
          data: { turbo_frame: "seat_#{@seat.id}" }
        ) do |f|
          div(class: "space-y-2") do
            f.collection_select(
              :game_id,
              @event.games,
              :id,
              ->(g) { "#{g.gm.display_name}'s table" },
              { selected: select_value },
              class: select_classes,
              data: { action: "change->seat-reassign#submit" }
            )

            # Stripe link
            if @seat.stripe_payment_intent_id.present?
              div(class: "text-xs") do
                a(
                  href: "https://dashboard.stripe.com/payments/#{@seat.stripe_payment_intent_id}",
                  target: "_blank",
                  rel: "noopener noreferrer",
                  class: "text-blue-600 hover:text-blue-800 inline-flex items-center gap-1"
                ) do
                  i(class: "fa-solid fa-external-link")
                  plain "Stripe"
                end
              end
            end
          end
        end
      end
    end
  end

  private

  def card_classes
    if @has_errors && @show_errors
      "border border-red-300 rounded-md p-3 bg-red-50"
    else
      "border border-gray-200 rounded-md p-3 bg-white"
    end
  end

  def select_classes
    base = "block w-full text-sm rounded-md"
    if @has_errors && @show_errors
      "#{base} border-red-300 focus:border-red-500 focus:ring-red-500"
    else
      "#{base} border-gray-300 focus:border-blue-500 focus:ring-blue-500"
    end
  end

  def select_value
    # If there are errors, show the original value
    @has_errors ? (@seat.game_id_was || @seat.game_id) : @seat.game_id
  end
end

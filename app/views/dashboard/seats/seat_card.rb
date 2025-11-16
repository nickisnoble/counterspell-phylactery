# frozen_string_literal: true

class Views::Dashboard::Seats::SeatCard < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::TurboFrameTag

  def initialize(seat:, event:)
    @seat = seat
    @event = event
  end

  def view_template
    turbo_frame_tag("seat_#{@seat.id}", class: "contents") do
      div(class: "border border-gray-200 rounded-md p-3 bg-white") do
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
              {},
              class: "block w-full text-sm rounded-md border-gray-300 focus:border-blue-500 focus:ring-blue-500",
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
end

class SeatsController < ApplicationController
  before_action :set_game
  before_action :authorize_purchase, only: [:create]

  def create
    @seat = @game.seats.build(seat_params)
    @seat.user = Current.user

    if @seat.valid?
      # Create Stripe checkout session
      session = Nocheckout::Session.create(
        line_items: [{
          price_data: {
            currency: "usd",
            product_data: {
              name: "#{@game.event.name} - Seat at #{@game.gm.display_name}'s table",
              description: "Event on #{@game.event.date.strftime('%B %d, %Y')}"
            },
            unit_amount: (@game.event.ticket_price * 100).to_i
          },
          quantity: 1
        }],
        mode: "payment",
        success_url: success_game_seats_url(@game, hero_id: @seat.hero_id),
        cancel_url: event_url(@game.event),
        metadata: {
          game_id: @game.id,
          user_id: Current.user.id,
          hero_id: @seat.hero_id
        }
      )

      redirect_to session.url, allow_other_host: true
    else
      redirect_to event_path(@game.event), alert: @seat.errors.full_messages.join(", ")
    end
  end

  def success
    # NOTE: This provides immediate user feedback after Stripe redirect.
    # The Stripe webhook (StripeWebhooksController#checkout_session_completed) is the
    # authoritative source of truth that verifies payment and creates the seat.
    # This callback may fire before the webhook, so we optimistically create the seat
    # for better UX. Both use find_or_initialize_by to prevent duplicates.
    @seat = @game.seats.find_or_initialize_by(
      user: Current.user,
      hero_id: params[:hero_id]
    )

    if @seat.new_record?
      @seat.stripe_payment_intent_id = params[:payment_intent]
      @seat.save!
    end

    redirect_to event_path(@game.event), notice: "Seat purchased successfully!"
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def authorize_purchase
    event = @game.event

    unless event.upcoming?
      redirect_to event_path(event), alert: "This event is not available for purchase"
      return
    end

    available_seats = @game.seat_count - @game.seats.where.not(user_id: nil).count
    if available_seats <= 0
      redirect_to event_path(event), alert: "This table is full"
      return
    end
  end

  def seat_params
    params.require(:seat).permit(:hero_id)
  end
end

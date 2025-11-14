class SeatsController < ApplicationController
  before_action :set_game

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
    # Find or create the seat with the Stripe payment
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

  def seat_params
    params.require(:seat).permit(:hero_id)
  end
end

class SeatsController < ApplicationController
  before_action :set_event_and_game, only: [:new, :create, :success, :show]
  before_action :authorize_purchase, only: [:new, :create]
  before_action :authorize_seat_viewing, only: [:show]

  def new
    taken_hero_ids = @game.seats.where.not(hero_id: nil).pluck(:hero_id)
    @available_heroes = Hero.where.not(id: taken_hero_ids).order(:name)

    # Calculate role availability (how many seats are taken per role)
    @role_counts = @game.seats
      .joins(:hero)
      .where.not(hero_id: nil)
      .group("heroes.role")
      .count
  end

  def show
    @seat = @game.seats.find(params[:id])
    render Views::Seats::Show.new(seat: @seat, game: @game, event: @event)
  end

  def create
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: Current.user.id,
      hero_id: params[:hero_id],
      role: params[:role_selection]
    )

    if form.valid?
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
        success_url: success_event_game_seats_url(@event, @game, hero_id: params[:hero_id]),
        cancel_url: event_url(@event),
        metadata: {
          game_id: @game.id,
          user_id: Current.user.id,
          hero_id: params[:hero_id]
        }
      )

      redirect_to session.url, allow_other_host: true
    else
      redirect_to event_path(@game.event), alert: form.errors.full_messages.join(", ")
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

    redirect_to event_game_seat_path(@event, @game, @seat), notice: "Seat purchased successfully!"
  end

  private

  def set_event_and_game
    @event = Event.find_by_slug!(params[:event_id])
    @game = @event.games.find(params[:game_id])
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

  def authorize_seat_viewing
    @seat = @game.seats.find(params[:id])
    unless Current.user&.admin? || @seat.user == Current.user
      redirect_to root_path, alert: "You can only view your own tickets"
    end
  end

  def seat_params
    params.require(:seat).permit(:hero_id)
  end
end

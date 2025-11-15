class StripeWebhooksController < NoCheckout::Stripe::WebhooksController
  STRIPE_SIGNING_SECRET = ENV["STRIPE_SIGNING_SECRET"]

  def checkout_session_completed
    # Validate metadata presence
    unless data.metadata&.game_id && data.metadata&.user_id
      Rails.logger.error "Webhook missing required metadata: session_id=#{data.id}"
      return
    end

    # Extract metadata from the session
    game_id = data.metadata.game_id
    user_id = data.metadata.user_id
    hero_id = data.metadata.hero_id

    # Find the game and user
    game = Game.find(game_id)
    user = User.find(user_id)

    # Create the seat
    seat = game.seats.find_or_initialize_by(user: user, hero_id: hero_id)
    seat.stripe_payment_intent_id = data.payment_intent
    seat.purchased_at = Time.current

    if seat.save
      Rails.logger.info "Created seat #{seat.id} for user #{user.email} in game #{game.id}"

      # Broadcast seat purchase confirmation
      EventChannel.broadcast_to(
        game.event,
        { type: "seat_purchased", game_id: game.id, hero_id: seat.hero_id }
      )
    else
      Rails.logger.error "Failed to save seat: #{seat.errors.full_messages.join(', ')}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Failed to create seat - record not found: #{e.message}"
  end
end

class StripeWebhooksController < NoCheckout::Stripe::WebhooksController
  STRIPE_SIGNING_SECRET = ENV["STRIPE_SIGNING_SECRET"]

  def checkout_session_completed
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
    seat.save!

    Rails.logger.info "Created seat #{seat.id} for user #{user.email} in game #{game.id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Failed to create seat: #{e.message}"
  end
end

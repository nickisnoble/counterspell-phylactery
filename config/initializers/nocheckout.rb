# frozen_string_literal: true

# Configure nocheckout for Stripe integration
# This gem provides a simplified Stripe checkout session interface
# that integrates with Rails and Action Cable for real-time updates.

require "nocheckout"

# Configure Stripe API key from credentials
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]

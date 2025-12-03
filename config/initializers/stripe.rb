Rails.configuration.stripe = {
  STRIPE_PUBLISHABLE_KEY: Rails.application.credentials.dig(:stripe, :STRIPE_PUBLISHABLE_KEY),
  STRIPE_SECRET_KEY: Rails.application.credentials.dig(:stripe, :STRIPE_SECRET_KEY)
}
Stripe.api_key = Rails.application.credentials.dig(:stripe, :STRIPE_SECRET_KEY)

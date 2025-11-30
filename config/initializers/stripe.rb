Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"] || "pk_test_51SZHBOQbUsuMifLwA8nQg6fdFEpJzE4GaX16rS95ZH0H0VYcvPwbs9fg4b3trg21AquQY28jvcjp8rBP9A8yU60D00lxPSAxvV",
  secret_key: ENV["STRIPE_SECRET_KEY"] || "***REMOVED***"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'] || 'pk_test_51Pe7AFB3HoEsxbVDXw9N0TTBpzmSbqoCaE4nD2gYWGA29EorDp7MOxyWITIQqU8CiyiaXS8nT1aaIl6CXdNeYfwy00IzFEBJUT',
  secret_key: ENV['STRIPE_SECRET_KEY'] || 'sk_test_51Pe7AFB3HoEsxbVDojfHVCLao7zm2zUZMPVuwYuqhndfoRojRWWKqhSV1MMcb4EEe1GscSLz4KlJDvrJNBGb3J57002AP7jFxv'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key] 
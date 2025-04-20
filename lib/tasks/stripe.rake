namespace :stripe do
  desc "Test Stripe integration"
  task test: :environment do
    puts "Testing Stripe integration..."
    
    # Check if Stripe is configured
    if Rails.configuration.stripe[:secret_key].blank?
      puts "❌ Stripe secret key is not configured. Please set STRIPE_SECRET_KEY environment variable."
      exit 1
    end
    
    if Rails.configuration.stripe[:publishable_key].blank?
      puts "❌ Stripe publishable key is not configured. Please set STRIPE_PUBLISHABLE_KEY environment variable."
      exit 1
    end
    
    if Rails.configuration.stripe[:signing_secret].blank?
      puts "❌ Stripe signing secret is not configured. Please set STRIPE_SIGNING_SECRET environment variable."
      exit 1
    end
    
    puts "✅ Stripe keys are configured."
    
    # Test creating a checkout session
    begin
      result = StripeService.create_checkout_session(
        1000, # 10 MYR
        'myr',
        { test: true },
        'http://localhost:3000/test/success',
        'http://localhost:3000/test/cancel'
      )
      
      if result[:success]
        puts "✅ Successfully created a checkout session: #{result[:session].id}"
        puts "   URL: #{result[:session].url}"
      else
        puts "❌ Failed to create a checkout session: #{result[:error]}"
        exit 1
      end
    rescue => e
      puts "❌ Error testing Stripe integration: #{e.message}"
      exit 1
    end
    
    puts "✅ Stripe integration test completed successfully."
  end
end 
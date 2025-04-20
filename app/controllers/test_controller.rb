class TestController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :require_otp_verification
  
  def stripe_test
    @amount = 1000 # RM 10.00 in cents
    @currency = 'myr'
    @success_url = test_success_url
    @cancel_url = test_cancel_url
    
    begin
      session = StripeService.create_checkout_session(
        @amount,
        @currency,
        @success_url,
        @cancel_url,
        { test: true }
      )
      redirect_to session.url, allow_other_host: true
    rescue Stripe::StripeError => e
      flash[:error] = "Payment failed: #{e.message}"
      redirect_to root_path
    end
  end
  
  def success
    flash[:success] = "Test payment successful!"
    redirect_to root_path
  end
  
  def cancel
    flash[:notice] = "Test payment cancelled"
    redirect_to root_path
  end
end 
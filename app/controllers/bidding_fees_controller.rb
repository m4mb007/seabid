class BiddingFeesController < ApplicationController
  before_action :authenticate_user!

  def new
    if current_user.bidding_fee_paid?
      redirect_to plate_numbers_path, notice: 'You have already paid the bidding fee.'
      return
    end

    @stripe_session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'myr',
          product_data: {
            name: 'Bidding Fee',
            description: 'One-time fee to enable bidding functionality'
          },
          unit_amount: 2000  # Amount in cents (RM20.00)
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: bidding_fees_success_url,
      cancel_url: bidding_fees_cancel_url,
      client_reference_id: current_user.id,
      customer_email: current_user.email
    )
  end

  def success
    current_user.update(bidding_fee_paid: true)
    redirect_to plate_numbers_path, notice: 'Bidding fee payment successful! You can now place bids.'
  end

  def cancel
    redirect_to plate_numbers_path, alert: 'Bidding fee payment was cancelled.'
  end
end 
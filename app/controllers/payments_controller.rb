class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plate_number
  before_action :check_highest_bidder
  
  def new
    @payment = Payment.new
    @bid = @plate_number.highest_bid
  end
  
  def create
    @payment = current_user.payments.build(payment_params)
    @payment.plate_number = @plate_number
    @payment.amount = @plate_number.current_price
    @payment.status = 'pending'
    
    if @payment.save
      # In production, this would redirect to Stripe checkout
      redirect_to dashboard_path, notice: 'Payment was successfully processed.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_plate_number
    @plate_number = PlateNumber.find(params[:plate_number_id])
  end
  
  def check_highest_bidder
    unless @plate_number.highest_bid&.user == current_user
      redirect_to @plate_number, alert: 'Only the highest bidder can make a payment.'
    end
  end
  
  def payment_params
    params.require(:payment).permit(:stripe_token)
  end
end

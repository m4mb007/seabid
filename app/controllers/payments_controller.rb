class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plate_number
  before_action :check_availability
  before_action :check_highest_bidder, unless: :direct_purchase?
  
  def new
    @payment = Payment.new
    @bid = @plate_number.highest_bid if @plate_number.auction?
  end
  
  def create

    puts "DEBUG PARAMS: #{params.inspect}" 

    @payment = current_user.payments.build
    @payment.plate_number = @plate_number
    @payment.amount = @plate_number.current_price
    @payment.status = 'pending'
    @payment.stripe_token = payment_params[:stripe_token]

    if @payment.save
      begin
        if @payment.process_payment
          redirect_to dashboard_path, notice: 'Payment was successfully processed.'
        else
          flash.now[:alert] = @payment.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end
      rescue => e
        flash.now[:alert] = e.message
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = @payment.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_plate_number
    @plate_number = PlateNumber.find(params[:plate_number_id])
  end
  
  def check_availability
    unless @plate_number.status == 'available'
      redirect_to @plate_number, alert: 'This plate number is no longer available.'
    end
  end

  def check_highest_bidder
    unless @plate_number.highest_bid&.user == current_user
      redirect_to @plate_number, alert: 'Only the highest bidder can make a payment.'
    end
  end

  def direct_purchase?
    @plate_number.direct_purchase?
  end
  
  def payment_params
    params.require(:payment).permit(:stripe_token)
  end
end

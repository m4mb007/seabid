# require 'stripe_service'

class PaymentsController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :set_plate_number, only: [:new, :create]
  before_action :check_availability, only: [:new, :create]
  before_action :check_highest_bidder, only: [:new, :create], unless: :direct_purchase?
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def new
    @amount = params[:amount].to_f
    @payment_type = params[:payment_type]
    @reference_id = params[:reference_id]
    
    # Create a payment record in pending state
    @payment = Payment.create!(
      user: current_user,
      amount: @amount,
      status: 'pending',
      payment_type: @payment_type,
      reference_id: @reference_id,
      plate_number: @plate_number
    )
    
    # For now, automatically mark the payment as completed
    @payment.update!(status: 'completed')
    
    # Handle different payment types
    case @payment_type
    when 'bidding_fee'
      current_user.update(bidding_fee_paid: true)
    when 'plate_number'
      @plate_number.update(status: 'paid')
    end
    
    # Redirect to thank you page
    redirect_to thank_you_payment_path(@payment)
  end

  def thank_you
    @payment = Payment.find(params[:id])
    @plate_number = @payment.plate_number
    
    # Verify the payment belongs to the current user
    unless @payment.user == current_user
      redirect_to root_path, alert: 'You are not authorized to view this payment.'
      return
    end
  end
  
  def index
    @payments = current_user.payments.order(created_at: :desc)
  end
  
  def show
    @payment = current_user.payments.find(params[:id])
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.configuration.stripe[:signing_secret]
    
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      head :bad_request
      return
    end
    
    # Handle the event
    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      handle_successful_payment(session)
    when 'checkout.session.expired'
      session = event.data.object
      handle_failed_payment(session)
    else
      puts "Unhandled event type: #{event.type}"
    end
    
    render json: { status: 'success' }
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
    @plate_number&.direct_purchase?
  end
  
  def handle_successful_payment(session)
    # Find payment record
    payment = Payment.find_by(stripe_payment_intent_id: session.id)
    
    if payment
      payment.update(status: 'completed')
      
      # Handle different payment types
      case payment.payment_type
      when 'bidding_fee'
        user = payment.user
        user.update(bidding_fee_paid: true)
      when 'plate_number'
        plate_number = PlateNumber.find(payment.reference_id)
        plate_number.update(status: 'paid')
      end
    end
  end
  
  def handle_failed_payment(session)
    # Find payment record
    payment = Payment.find_by(stripe_payment_intent_id: session.id)
    
    if payment
      payment.update(status: 'failed')
    end
  end
end

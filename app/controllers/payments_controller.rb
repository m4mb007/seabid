require 'stripe_service'

class PaymentsController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :set_plate_number, only: [:new, :create, :thank_you]
  before_action :check_availability, only: [:new, :create]
  before_action :check_highest_bidder, only: [:new, :create], unless: :direct_purchase?
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
  def new
    @amount = params[:amount].to_i
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
    
    # Create a checkout session
    success_url = thank_you_payment_url(@payment)
    cancel_url = plate_number_url(@plate_number)
    
    result = StripeService.create_checkout_session(
      @amount * 100, # Convert to cents
      'myr',
      {
        payment_id: @payment.id,
        user_id: current_user.id,
        payment_type: @payment_type,
        reference_id: @reference_id
      },
      success_url,
      cancel_url
    )
    
    if result[:success]
      # Store the session ID in the payment record
      @payment.update!(stripe_payment_intent_id: result[:session].id)
      
      # Redirect to Stripe Checkout
      redirect_to result[:session].url, allow_other_host: true
    else
      @payment.update!(status: 'failed')
      flash[:error] = result[:error]
      redirect_to plate_number_path(@plate_number), alert: result[:error]
    end
  end

  def thank_you
    @payment = Payment.find(params[:id])
    
    # Verify the payment belongs to the current user
    unless @payment.user == current_user
      redirect_to root_path, alert: 'You are not authorized to view this payment.'
      return
    end
    
    # If the payment is still pending, check with Stripe
    if @payment.status == 'pending'
      result = StripeService.retrieve_checkout_session(@payment.stripe_payment_intent_id)
      
      if result[:success] && result[:session].payment_status == 'paid'
        @payment.update!(status: 'completed')
        
        # Handle different payment types
        case @payment.payment_type
        when 'bidding_fee'
          current_user.update(bidding_fee_paid: true)
        when 'plate_number'
          @plate_number.update(status: 'paid')
        end
      end
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

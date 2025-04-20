class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plate_number
  before_action :check_availability
  before_action :check_highest_bidder, unless: :direct_purchase?
  
  def new
    @payment = Payment.new
    @bid = @plate_number.highest_bid if @plate_number.auction?
    
    # Create payment intent for FPX
    @payment = current_user.payments.build
    @payment.plate_number = @plate_number
    @payment.amount = @plate_number.current_price
    @payment.status = 'pending'
    
    if @payment.save && @payment.process_payment
      @client_secret = Stripe::PaymentIntent.retrieve(@payment.payment_intent_id).client_secret
    else
      flash.now[:alert] = @payment.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end
  
  def create
    @payment = Payment.find_by(id: params[:payment_id])
    
    if @payment.nil?
      # Create a new payment with billing info
      @payment = current_user.payments.build(payment_params)
      @payment.plate_number = @plate_number
      @payment.amount = @plate_number.current_price
      @payment.status = 'processing'
      
      # Save billing information to Payment record
      @payment.billing_name = params[:full_name]
      @payment.billing_email = params[:email]
      @payment.billing_phone = params[:phone]
      @payment.billing_address = params[:address]
      @payment.billing_city = params[:city]
      @payment.billing_state = params[:state]
      @payment.billing_postal_code = params[:postal_code]
      @payment.billing_ic_number = params[:ic_number]
      
      # Process payment with Stripe token
      if @payment.save && @payment.confirm_payment_with_token(params[:stripe_token])
        redirect_to dashboard_path, notice: 'Payment was successfully processed.'
      else
        flash.now[:alert] = @payment.errors.full_messages.to_sentence || 'Payment processing failed'
        render :new, status: :unprocessable_entity
      end
    elsif @payment&.confirm_payment(params[:payment_intent_id])
      redirect_to dashboard_path, notice: 'Payment was successfully processed.'
    else
      flash.now[:alert] = @payment&.errors&.full_messages&.to_sentence || 'Payment confirmation failed'
      render :new, status: :unprocessable_entity
    end
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      status 400
      return
    end

    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      payment = Payment.find_by(payment_intent_id: payment_intent.id)
      payment&.confirm_payment(payment_intent.id)
    when 'payment_intent.payment_failed'
      payment_intent = event.data.object
      payment = Payment.find_by(payment_intent_id: payment_intent.id)
      payment&.update(status: 'failed')
    end

    head :ok
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
    params.permit(:stripe_token, :payment_intent_id)
  end
end

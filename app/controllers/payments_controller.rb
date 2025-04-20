require 'stripe_service'

class PaymentsController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :set_plate_number, only: [:new, :create, :thank_you]
  before_action :check_availability, only: [:new, :create]
  before_action :check_highest_bidder, only: [:new, :create], unless: :direct_purchase?
  skip_before_action :verify_authenticity_token, only: [:webhook]
  
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
    @plate_number&.direct_purchase?
  end
  
  def payment_params
    params.require(:payment).permit(:stripe_token)
  end
end

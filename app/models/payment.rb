class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :plate_number
  
  attr_accessor :stripe_token, :payment_intent_id
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validates :payment_type, presence: true, inclusion: { in: %w[bidding_fee plate_number] }
  validates :reference_id, presence: true
  validate :user_must_be_highest_bidder, if: :auction_payment?
  
  def process_payment
    return false if skip_validation
    
    begin
      update!(status: 'processing')
      
      # Create a Payment Intent for FPX payment
      payment_intent = Stripe::PaymentIntent.create(
        amount: (amount * 100).to_i, # amount in cents
        currency: 'myr',
        payment_method_types: ['fpx'],
        metadata: {
          plate_number: plate_number.number,
          user_email: user.email
        }
      )
      
      # Store the payment intent ID
      update!(payment_intent_id: payment_intent.id)
      
      true
    rescue Stripe::StripeError => e
      handle_payment_error(e.message)
      false
    rescue => e
      handle_payment_error("Payment processing failed: #{e.message}")
      false
    end
  end

  def confirm_payment(payment_intent_id)
    begin
      payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
      
      if payment_intent.status == 'succeeded'
        plate_number.update!(status: 'booked')
        update!(status: 'completed')
        true
      else
        update!(status: 'failed')
        errors.add(:base, "Payment failed: #{payment_intent.last_payment_error&.message}")
        false
      end
    rescue Stripe::StripeError => e
      handle_payment_error(e.message)
      false
    rescue => e
      handle_payment_error("Payment confirmation failed: #{e.message}")
      false
    end
  end
  
  def stripe_session_id
    stripe_payment_intent_id
  end
  
  def stripe_session_id=(value)
    self.stripe_payment_intent_id = value
  end
  
  private
  
  def auction_payment?
    payment_type == 'plate_number' && plate_number&.auction?
  end
  
  def skip_validation
    @skip_validation ||= false
  end
  
  def user_must_be_highest_bidder
    return unless plate_number && user
    highest_bid = plate_number.highest_bid
    unless highest_bid && highest_bid.user_id == user_id
      errors.add(:user, 'must be the highest bidder')
    end
  end
  
  def handle_payment_error(message)
    Rails.logger.error(message)
    update!(status: 'failed')
    errors.add(:base, message)
  end
end

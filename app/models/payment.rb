class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :plate_number
  
  attr_accessor :stripe_token
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validate :user_must_be_highest_bidder, if: :auction_payment?
  validates :stripe_token, presence: true, on: :create
  
  def process_payment
    return false if skip_validation
    
    begin
      update!(status: 'processing')
      
      # This would integrate with Stripe in production
      charge = Stripe::Charge.create(
        amount: (amount * 100).to_i,
        currency: 'myr',
        source: stripe_token,
        description: "Payment for plate number #{plate_number.number}"
      )
      
      if charge.status == 'succeeded'
        plate_number.update!(status: 'booked')
        update!(status: 'completed')
        true
      else
        update!(status: 'failed')
        errors.add(:base, "Payment failed: #{charge.failure_message}")
        false
      end
    rescue Stripe::CardError => e
      handle_payment_error(e.message)
      false
    rescue Stripe::InvalidRequestError => e
      handle_payment_error("Invalid payment request: #{e.message}")
      false
    rescue => e
      handle_payment_error("Payment processing failed: #{e.message}")
      false
    end
  end
  
  private
  
  def auction_payment?
    plate_number&.auction? && !skip_validation
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

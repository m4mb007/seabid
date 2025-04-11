class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :plate_number
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validate :user_must_be_highest_bidder, unless: :skip_validation
  
  after_create :process_payment, unless: :skip_validation
  
  attr_accessor :skip_validation
  
  private
  
  def user_must_be_highest_bidder
    return unless plate_number && user
    highest_bid = plate_number.highest_bid
    unless highest_bid && highest_bid.user_id == user_id
      errors.add(:user, 'must be the highest bidder')
    end
  end
  
  def process_payment
    # This would integrate with Stripe in production
    if valid?
      update(status: 'processing')
      # Process payment logic here
      plate_number.update(status: 'paid')
      update(status: 'completed')
    else
      update(status: 'failed')
    end
  end
end

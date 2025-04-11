class Bid < ApplicationRecord
  belongs_to :user
  belongs_to :plate_number
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :amount_must_be_higher_than_current_price, unless: :skip_validation
  validate :plate_number_must_be_available, unless: :skip_validation
  
  after_create :update_plate_number_price, unless: :skip_validation
  
  attr_accessor :skip_validation
  
  private
  
  def amount_must_be_higher_than_current_price
    return unless plate_number && amount
    if amount <= plate_number.current_price
      errors.add(:amount, 'must be higher than current price')
    end
  end
  
  def plate_number_must_be_available
    return unless plate_number
    unless plate_number.status == 'available'
      errors.add(:plate_number, 'is not available for bidding')
    end
  end
  
  def update_plate_number_price
    plate_number.update(current_price: amount)
  end
end

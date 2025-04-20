class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :bids, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :plate_numbers, through: :bids
  has_many :purchased_plates, through: :payments, source: :plate_number
  
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  validate :prevent_admin_from_bidding, if: :admin?

  def can_bid?
    return false if admin?
    bidding_fee_paid?
  end

  def pay_bidding_fee(token)
    return false if admin?
    return true if bidding_fee_paid?
    return false if token.blank?

    begin
      Rails.logger.info "Attempting to create Stripe charge with token: #{token.present? ? 'present' : 'missing'}"
      
      charge = Stripe::Charge.create({
        amount: SeaBid::BIDDING_FEE * 100, # amount in cents
        currency: 'myr',
        source: token,
        description: "Bidding fee for #{email}"
      })
      
      if charge.paid
        update(bidding_fee_paid: true)
        return true
      end
    rescue Stripe::CardError => e
      errors.add(:base, e.message)
      Rails.logger.error "Stripe card error: #{e.message}"
      return false
    rescue Stripe::InvalidRequestError => e
      errors.add(:base, "Invalid payment information: #{e.message}")
      Rails.logger.error "Stripe invalid request error: #{e.message}"
      return false
    rescue => e
      errors.add(:base, "Payment processing failed: #{e.message}")
      Rails.logger.error "Stripe error: #{e.message}"
      return false
    end
    
    false
  end

  def admin?
    admin
  end

  private

  def prevent_admin_from_bidding
    if bids.any? || payments.any?
      errors.add(:base, 'Administrators cannot place bids or make purchases')
    end
  end
end

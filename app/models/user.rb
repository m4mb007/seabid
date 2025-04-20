class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :bids, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :plate_numbers, through: :bids
  has_many :purchased_plates, through: :payments, source: :plate_number
  
  # Account type enum
  enum :account_type, { seafarer: 0, agent: 1, company: 2 }

  # Basic validations for all users
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :ic_number, presence: true, uniqueness: true
  validates :phone_number, presence: true
  validates :account_type, presence: true

  # Conditional validations based on account type
  validates :seafarer_id, presence: true, uniqueness: true, if: :seafarer?
  validates :company_registration_number, presence: true, uniqueness: true, if: :agent?
  validates :street, :postcode, :state, :country, presence: true, if: :agent?
  validate :prevent_admin_from_bidding, if: :admin?

  # OTP verification
  before_create :generate_otp
  before_save :check_ic_number_change, if: :ic_number_changed?

  # Validations
  validates :ic_number, presence: true, uniqueness: true, unless: :ic_number_changed?
  validates :email_verified, inclusion: { in: [true, false] }
  validates :otp_verified, inclusion: { in: [true, false] }
  validates :otp_sent_at, presence: true, if: :otp_verified?

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

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_address
    [street, postcode, state, country].compact.join(', ')
  end

  # Verification methods
  def mark_email_as_verified!
    update!(email_verified: true)
  end

  def mark_otp_as_verified!
    update!(otp_verified: true, otp_sent_at: Time.current)
  end

  def reset_verification!
    update!(email_verified: false, otp_verified: false, otp_sent_at: nil)
  end

  def fully_verified?
    email_verified? && otp_verified?
  end

  def send_otp
    Rails.logger.info "Sending OTP..."
    generate_otp
    
    if Rails.env.development?
      Rails.logger.info "Development mode - OTP: #{otp_code}"
    else
      UserMailer.otp_email(self).deliver_now
    end
  end

  def resend_otp
    Rails.logger.info "Resending OTP..."
    generate_otp
    
    if Rails.env.development?
      Rails.logger.info "Development mode - OTP: #{otp_code}"
    else
      UserMailer.otp_email(self).deliver_now
    end
  end

  def verify_otp(code)
    Rails.logger.info "Verifying OTP..."
    Rails.logger.info "Input code: #{code}"
    Rails.logger.info "Stored OTP: #{otp_code}"
    Rails.logger.info "OTP Sent At: #{otp_sent_at}"
    Rails.logger.info "OTP Expired?: #{otp_expired?}"
    
    return false if otp_expired?
    
    if otp_code == code
      Rails.logger.info "OTP verified successfully"
      # Update both verification flags
      update!(
        otp_verified: true,
        email_verified: true,
        otp_code: nil,
        otp_sent_at: nil
      )
      Rails.logger.info "User verification status after update:"
      Rails.logger.info "OTP Verified: #{otp_verified?}"
      Rails.logger.info "Email Verified: #{email_verified?}"
      true
    else
      Rails.logger.info "OTP verification failed - codes don't match"
      false
    end
  end

  def otp_expired?
    return false if otp_sent_at.nil?
    (Time.current - otp_sent_at) > 5.minutes
  end

  def otp_verified?
    otp_verified == true
  end

  def verification_status
    if otp_verified?
      { text: "✅ Verified", class: "bg-green-100 text-green-800" }
    else
      { text: "⚠️ Not Verified", class: "bg-yellow-100 text-yellow-800" }
    end
  end

  private

  def prevent_admin_from_bidding
    if bids.any? || payments.any?
      errors.add(:base, 'Administrators cannot place bids or make purchases')
    end
  end

  def generate_otp
    Rails.logger.info "Generating OTP..."
    self.otp_code = rand(100000..999999).to_s
    self.otp_sent_at = Time.current
    self.otp_verified = false
    self.email_verified = false
    
    Rails.logger.info "Generated OTP: #{otp_code}"
    Rails.logger.info "OTP Sent At: #{otp_sent_at}"
    
    # Save immediately to ensure OTP is persisted
    save(validate: false)
    
    Rails.logger.info "OTP after save: #{otp_code}"
    Rails.logger.info "OTP in database: #{self.class.find(id).otp_code}"
  end

  def check_ic_number_change
    if persisted? && ic_number_was.present?
      errors.add(:ic_number, "cannot be changed after registration")
      throw(:abort)
    end
  end
end

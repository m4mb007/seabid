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

  def can_bid?
    return false if admin?
    true # Allow bidding by default
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

  # Verification methods always return true
  def mark_email_as_verified!
    true
  end

  def mark_otp_as_verified!
    true
  end

  def reset_verification!
    true
  end

  def fully_verified?
    true
  end

  def otp_verified?
    true
  end

  def verification_status
    { text: "✅ Verified", class: "bg-green-100 text-green-800" }
  end

  private

  def prevent_admin_from_bidding
    if bids.any? || payments.any?
      errors.add(:base, 'Administrators cannot place bids or make purchases')
    end
  end
end

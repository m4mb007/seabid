class PlateNumber < ApplicationRecord
  has_many :bids, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :bidders, through: :bids, source: :user
  
  validates :number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[available booked paid] }
  validates :category, presence: true, inclusion: { in: %w[prime popular main] }
  validates :starting_price, presence: true, numericality: { greater_than: 0 }
  validates :current_price, presence: true, numericality: { greater_than_or_equal_to: :starting_price }
  validates :end_time, presence: true
  validates :sale_type, presence: true, inclusion: { in: %w[auction direct] }
  
  validate :validate_pelaut_format
  before_validation :format_number
  before_validation :set_default_end_time
  
  scope :available, -> { where(status: 'available') }
  scope :ending_soon, -> { where('end_time <= ?', 24.hours.from_now).available.auction }
  scope :by_category, ->(category) { where(category: category) }
  scope :auction, -> { where(sale_type: 'auction') }
  scope :direct, -> { where(sale_type: 'direct') }
  
  def time_remaining
    return 0 if end_time.past?
    (end_time - Time.current).to_i
  end
  
  def highest_bid
    bids.order(amount: :desc).first
  end

  def direct_purchase?
    sale_type == 'direct'
  end

  def auction?
    sale_type == 'auction'
  end
  
  def self.ransackable_attributes(auth_object = nil)
    # List only the attributes you want to be searchable
    ["number", "category", "status", "current_price", "starting_price", "end_time", "sale_type"]
  end

  # Optional: If you want to control which associations can be searched
  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def validate_pelaut_format
    unless number.match?(/^PELAUT\s*\d+$/)
      errors.add(:number, 'must start with PELAUT followed by a number')
    end
  end

  def format_number
    return unless number.present?
    # Convert to uppercase and ensure proper spacing
    self.number = number.upcase.gsub(/^(PELAUT)\s*(\d+)$/, '\1 \2')
  end
  
  def set_default_end_time
    # For direct sales, set a far future date as end time if not provided
    if direct_purchase? && (end_time.blank? || end_time_changed?)
      self.end_time = 1.year.from_now
    elsif auction? && end_time.blank?
      # For auctions, set a default end time of 7 days from now if not provided
      self.end_time = 7.days.from_now
    end
  end
end


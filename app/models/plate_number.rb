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
  
  scope :available, -> { where(status: 'available') }
  scope :ending_soon, -> { where('end_time <= ?', 24.hours.from_now).available }
  scope :by_category, ->(category) { where(category: category) }
  
  def time_remaining
    return 0 if end_time.past?
    (end_time - Time.current).to_i
  end
  
  def highest_bid
    bids.order(amount: :desc).first
  end

  
  def self.ransackable_attributes(auth_object = nil)
    # List only the attributes you want to be searchable
    ["number", "category", "status", "current_price", "starting_price", "end_time"]
  end

  # Optional: If you want to control which associations can be searched
  def self.ransackable_associations(auth_object = nil)
    []
  end

end


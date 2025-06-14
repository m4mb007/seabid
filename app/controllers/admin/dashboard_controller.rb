class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.where(admin: false).count
    @total_admins = User.where(admin: true).count
    @total_plate_numbers = PlateNumber.count
    @total_sold_plates = PlateNumber.where(status: ['booked', 'paid']).count
    @total_bids = Bid.count
    @total_payments = Payment.count
    @total_revenue = Payment.where(status: 'completed').sum(:amount)
    
    @recent_users = User.where(admin: false).order(created_at: :desc).limit(5)
    @recent_payments = Payment.includes(:user, :plate_number).order(created_at: :desc).limit(5)
    @recent_plate_numbers = PlateNumber.order(created_at: :desc).limit(5)
  end
end 
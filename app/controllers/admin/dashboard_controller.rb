module Admin
  class DashboardController < BaseController
  def index
      @total_users = User.count
    @total_plate_numbers = PlateNumber.count
    @total_bids = Bid.count
    @total_payments = Payment.count
    
      # Get recent records for the dashboard
      @recent_users = User.order(created_at: :desc).limit(5)
    @recent_payments = Payment.includes(:user, :plate_number).order(created_at: :desc).limit(5)
    @recent_plate_numbers = PlateNumber.order(created_at: :desc).limit(5)
    end
  end
end 
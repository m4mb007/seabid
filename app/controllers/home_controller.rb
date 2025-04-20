class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  
  def index
    @featured_plates = PlateNumber.available.order(created_at: :desc).limit(6)
    @ending_soon = PlateNumber.ending_soon.limit(6)
    @categories = %w[prime popular main]
  end
  
  def dashboard
    @my_active_bids = current_user.bids.joins(:plate_number)
                                 .where(plate_numbers: { status: 'available' })
                                 .order(created_at: :desc)
                                 
    @my_purchased_plates = current_user.purchased_plates
                                     .where(status: %w[booked paid])
                                     .order(created_at: :desc)
                                     
    @won_bids = current_user.bids.joins(:plate_number)
                           .where(plate_numbers: { status: %w[booked paid] })
                           .order(created_at: :desc)
  end
  
  def my_bids
    @bids = current_user.bids
             .includes(:plate_number)
             .order(created_at: :desc)
             .page(params[:page])
  end
  
  def my_payments
    @payments = current_user.payments
                .includes(:plate_number)
                .order(created_at: :desc)
                .page(params[:page])
                .per(20)
  end

  # app/controllers/home_controller.rb
def my_bids
  @bids = current_user.bids
             .includes(:plate_number)
             .order(created_at: :desc)
             .page(params[:page])
end
end

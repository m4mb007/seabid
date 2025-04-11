class PlateNumbersController < ApplicationController
  before_action :set_plate_number, only: [:show]
  
  def index
    @q = PlateNumber.ransack(params[:q])
    @plate_numbers = @q.result(distinct: true)
                      .available
                      .includes(:bids)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(12)
                      
    @categories = %w[prime popular main]
  end
  
  def show
    @bid = Bid.new
    @highest_bid = @plate_number.highest_bid
    @recent_bids = @plate_number.bids.order(created_at: :desc).limit(5)
  end
  
  private
  
  def set_plate_number
    @plate_number = PlateNumber.find(params[:id])
  end
end



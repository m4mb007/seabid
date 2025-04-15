class PlateNumbersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :require_admin!, only: [:new, :create]
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

  def new
    @plate_number = PlateNumber.new
  end

  def create
    @plate_number = PlateNumber.new(plate_number_params)
    @plate_number.status = 'available'
    @plate_number.current_price = @plate_number.starting_price
    
    if @plate_number.save
      redirect_to @plate_number, notice: 'Plate number was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_plate_number
    @plate_number = PlateNumber.find(params[:id])
  end

  def plate_number_params
    params.require(:plate_number).permit(:number, :category, :starting_price, :end_time, :sale_type)
  end
  
  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'You are not authorized to perform this action.'
    end
  end
end



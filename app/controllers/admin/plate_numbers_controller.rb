class Admin::PlateNumbersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_plate_number, only: [:show, :edit, :update, :destroy]
  
  def index
    @plate_numbers = PlateNumber.includes(:bids, :payments)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(20)
  end
  
  def show
    @bids = @plate_number.bids.includes(:user).order(created_at: :desc)
    @payments = @plate_number.payments.includes(:user).order(created_at: :desc)
  end
  
  def new
    @plate_number = PlateNumber.new
  end
  
  def create
    @plate_number = PlateNumber.new(plate_number_params)
    @plate_number.current_price = @plate_number.starting_price
    @plate_number.status = 'available'
    
    # Set the end time appropriately for direct sales
    if @plate_number.direct_purchase? && params[:plate_number][:end_time].blank?
      @plate_number.end_time = 1.year.from_now
    end
    
    if @plate_number.save
      redirect_to admin_plate_number_path(@plate_number), notice: 'Plate number was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    # Handle the end time for direct sales
    if @plate_number.direct_purchase? && params[:plate_number][:end_time].blank?
      params[:plate_number][:end_time] = 1.year.from_now
    end
    
    if @plate_number.update(plate_number_params)
      redirect_to admin_plate_number_path(@plate_number), notice: 'Plate number was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @plate_number.bids.exists? || @plate_number.payments.exists?
      redirect_to admin_plate_numbers_path, alert: 'Cannot delete plate number with bids or payments.'
    else
      @plate_number.destroy
      redirect_to admin_plate_numbers_path, notice: 'Plate number was successfully deleted.'
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
      redirect_to root_path, alert: 'You are not authorized to access this area.'
    end
  end
end 
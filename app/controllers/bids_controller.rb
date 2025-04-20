class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plate_number
  before_action :check_bidding_fee_paid
  before_action :require_otp_verification
  
  def new
    @bid = Bid.new
    @current_price = @plate_number.current_price
  end

  def create
    @bid = current_user.bids.build(bid_params)
    @bid.plate_number = @plate_number
    
    respond_to do |format|
      if @bid.save
        format.html { redirect_to @plate_number, notice: 'Bid was successfully placed.' }
        format.json { render json: @bid, status: :created }
      else
        format.html { redirect_to @plate_number, alert: @bid.errors.full_messages.join(', ') }
        format.json { render json: @bid.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def set_plate_number
    @plate_number = PlateNumber.find(params[:plate_number_id])
  end
  
  def bid_params
    params.require(:bid).permit(:amount)
  end

  def check_bidding_fee_paid
    unless current_user.can_bid?
      redirect_to new_bidding_fee_path, alert: 'You need to pay the bidding fee before placing bids.'
    end
  end
end

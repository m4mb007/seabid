class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_bidding_fee
  before_action :set_plate_number
<<<<<<< Updated upstream
  before_action :check_bidding_fee_paid
=======
  before_action :require_otp_verification
>>>>>>> Stashed changes
  
  def new
    @bid = @plate_number.bids.build
    @current_price = @plate_number.current_price
  end

  def create
    @bid = @plate_number.bids.build(bid_params)
    @bid.user = current_user
    
    if @bid.save
      redirect_to @plate_number, notice: 'Bid was successfully placed.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_plate_number
    @plate_number = PlateNumber.find(params[:plate_number_id])
  end
  
  def bid_params
    params.require(:bid).permit(:amount)
  end

  def check_bidding_fee
    unless current_user.bidding_fee_paid?
      redirect_to new_bidding_fee_path, alert: 'You need to pay the bidding fee before placing bids.'
    end
  end
end

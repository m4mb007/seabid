class BiddingFeesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    if current_user.pay_bidding_fee(params[:stripe_token])
      redirect_to plate_numbers_path, notice: 'Bidding fee payment successful! You can now place bids.'
    else
      flash.now[:alert] = current_user.errors.full_messages.to_sentence || 'Unable to process payment. Please try again.'
      render :new, status: :unprocessable_entity
    end
  end
end 
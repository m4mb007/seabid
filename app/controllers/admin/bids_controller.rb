module Admin
  class BidsController < BaseController
    def index
      @bids = Bid.includes(:user, :plate_number).order(created_at: :desc)
    end
 
    def show
      @bid = Bid.find(params[:id])
    end
  end
end 
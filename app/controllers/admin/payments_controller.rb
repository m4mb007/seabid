module Admin
  class PaymentsController < BaseController
  def index
      @payments = Payment.includes(:user, :plate_number).order(created_at: :desc)
  end
  
  def show
    @payment = Payment.find(params[:id])
    end
  end
end 
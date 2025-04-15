class Admin::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  
  def index
    @payments = Payment.includes(:user, :plate_number)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(20)
                      
    @total_completed = Payment.where(status: 'completed').sum(:amount)
    @total_processing = Payment.where(status: 'processing').sum(:amount)
    @total_failed = Payment.where(status: 'failed').sum(:amount)
  end
  
  def show
    @payment = Payment.find(params[:id])
  end
  
  private
  
  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'You are not authorized to access this area.'
    end
  end
end 
class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  def index
    @users = User.where(admin: false)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(20)
  end

  def show
    @bids = @user.bids.includes(:plate_number).order(created_at: :desc)
    @payments = @user.payments.includes(:plate_number).order(created_at: :desc)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.admin?
      redirect_to admin_users_path, alert: 'Cannot delete admin users.'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :bidding_fee_paid)
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'You are not authorized to access this area.'
    end
  end
end 
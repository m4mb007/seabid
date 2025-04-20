class OtpVerificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_verified, except: [:resend]

  def new
    @user = current_user
  end

  def create
    @user = current_user
    otp_code = params[:otp_code]
    
    Rails.logger.info "OTP Verification Attempt:"
    Rails.logger.info "User ID: #{@user.id}"
    Rails.logger.info "Input OTP: #{otp_code}"
    Rails.logger.info "Stored OTP: #{@user.otp_code}"
    Rails.logger.info "OTP Sent At: #{@user.otp_sent_at}"
    Rails.logger.info "Current OTP Verified: #{@user.otp_verified?}"
    
    if @user.verify_otp(otp_code)
      Rails.logger.info "OTP verification successful"
      Rails.logger.info "OTP Verified after verification: #{@user.reload.otp_verified?}"
      
      respond_to do |format|
        format.html { redirect_to dashboard_path, notice: 'You have successfully verified your OTP.' }
        format.turbo_stream { 
          flash.now[:notice] = 'You have successfully verified your OTP.'
          render turbo_stream: turbo_stream.replace("verification_status", 
            partial: "shared/verification_status", 
            locals: { user: @user }
          )
        }
      end
    else
      Rails.logger.info "OTP verification failed"
      flash.now[:alert] = if @user.otp_expired?
        'Verification code has expired. Please request a new one.'
      else
        'Invalid verification code. Please try again.'
      end
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    @user = current_user
    
    if @user.otp_sent_at.present? && (Time.current - @user.otp_sent_at) < 1.minute
      redirect_to new_otp_verification_path, alert: 'Please wait a moment before requesting another code.'
      return
    end
    
    @user.resend_otp
    redirect_to new_otp_verification_path, notice: 'New verification code has been sent to your email.'
  end

  private

  def redirect_if_verified
    if current_user&.otp_verified?
      redirect_to dashboard_path, alert: 'Your account is already verified.'
    end
  end
end 
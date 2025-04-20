class UserMailer < ApplicationMailer
  default from: 'noreply@seabid.com'

  def otp_email(user)
    @user = user
    @otp = user.otp_code
    
    Rails.logger.info "Mailer OTP Debug:"
    Rails.logger.info "User ID: #{user.id}"
    Rails.logger.info "OTP Code: #{@otp}"
    Rails.logger.info "OTP Sent At: #{user.otp_sent_at}"
    
    mail(
      to: @user.email,
      subject: 'Your SeaBid Verification Code'
    )
  end
end 
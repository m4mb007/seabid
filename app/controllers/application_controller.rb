class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :require_otp_verification, unless: :otp_verification_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :account_type, 
      :first_name, 
      :last_name, 
      :phone_number, 
      :ic_number, 
      :seafarer_id, 
      :company_registration_number,
      :street,
      :postcode,
      :state,
      :country
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :ic_number, :seafarer_id, :phone_number, :street, :postcode, :state, :country])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      dashboard_path
    end
  end

  private

  def otp_verification_controller?
    controller_name == 'otp_verifications'
  end

  def require_otp_verification
    return unless user_signed_in?
    return if current_user.otp_verified?
    
    # Store the requested URL to redirect back after verification
    session[:return_to] = request.original_url
    
    flash[:alert] = "You must verify your email address via OTP before continuing."
    redirect_to new_otp_verification_path
  end
end

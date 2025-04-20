class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
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
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
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
  end

  def after_sign_up_path_for(resource)
    # Send OTP email
    UserMailer.otp_email(resource).deliver_later
    # Redirect to OTP verification page
    new_otp_verification_path
  end
end 
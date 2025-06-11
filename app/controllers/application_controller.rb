class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone_number,
      :street, :postcode, :state, :country,
      :seafarer, :seafarer_id, :seafarer_expiry,
      :company_name, :company_registration_number, :business_license
    ])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      dashboard_path
    end
  end
end

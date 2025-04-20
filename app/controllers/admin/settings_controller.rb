module Admin
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @settings = Setting.all
    end

    def update
      @setting = Setting.find(params[:id])
      if @setting.update(setting_params)
        redirect_to admin_settings_path, notice: 'Setting was successfully updated.'
      else
        redirect_to admin_settings_path, alert: 'Failed to update setting.'
      end
    end

    private

    def require_admin
      unless current_user.admin?
        redirect_to root_path, alert: 'You are not authorized to access this area.'
      end
    end

    def setting_params
      params.require(:setting).permit(:value)
    end
  end
end 
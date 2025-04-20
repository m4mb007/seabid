class AddDefaultValuesToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :otp_verified, from: nil, to: false
    change_column_default :users, :email_verified, from: nil, to: false
  end
end 
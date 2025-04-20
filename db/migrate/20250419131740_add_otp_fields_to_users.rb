class AddOtpFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :otp_verified, :boolean, default: false, null: false
    add_column :users, :otp_sent_at, :datetime
    add_column :users, :email_verified, :boolean, default: false, null: false
  end
end

class AddAgentFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :company_registration_number, :string
    add_column :users, :business_license, :string
    add_column :users, :seafarer_expiry, :date
  end
end 
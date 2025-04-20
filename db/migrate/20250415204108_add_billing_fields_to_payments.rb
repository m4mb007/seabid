class AddBillingFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :billing_name, :string
    add_column :payments, :billing_email, :string
    add_column :payments, :billing_phone, :string
    add_column :payments, :billing_address, :text
    add_column :payments, :billing_city, :string
    add_column :payments, :billing_state, :string
    add_column :payments, :billing_postal_code, :string
    add_column :payments, :billing_ic_number, :string
  end
end

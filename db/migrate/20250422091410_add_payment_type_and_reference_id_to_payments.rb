class AddPaymentTypeAndReferenceIdToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :payment_type, :string
    add_column :payments, :reference_id, :string
  end
end 
class AddPaymentIntentIdToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :payment_intent_id, :string
    add_index :payments, :payment_intent_id
  end
end

class AddCompanyRegistrationNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :company_registration_number, :string
  end
end

class RenamePaymentIntentIdToStripePaymentIntentId < ActiveRecord::Migration[7.0]
  def change
    rename_column :payments, :payment_intent_id, :stripe_payment_intent_id
  end
end

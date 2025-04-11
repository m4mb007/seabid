class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.references :plate_number, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateBiddingFees < ActiveRecord::Migration[8.0]
  def change
    create_table :bidding_fees do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.references :user, null: false, foreign_key: true
      t.references :bid, null: false, foreign_key: true

      t.timestamps
    end
  end
end

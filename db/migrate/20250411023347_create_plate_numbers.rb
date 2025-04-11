class CreatePlateNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :plate_numbers do |t|
      t.string :number
      t.string :status
      t.string :category
      t.decimal :starting_price
      t.decimal :current_price
      t.datetime :end_time

      t.timestamps
    end
  end
end

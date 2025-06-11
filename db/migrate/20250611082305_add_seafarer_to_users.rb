class AddSeafarerToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :seafarer, :boolean, null: false, default: false
  end
end

class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ic_number, :string
    add_column :users, :address, :text
    add_column :users, :phone_number, :string
    add_column :users, :seafarer_id, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end

class AddAddressFieldsToUsers < ActiveRecord::Migration[8.0]
  def up
    # Add new columns
    add_column :users, :street, :string
    add_column :users, :postcode, :string
    add_column :users, :state, :string
    add_column :users, :country, :string

    # Copy data from the old address column if it exists
    if column_exists?(:users, :address)
      User.reset_column_information
      User.find_each do |user|
        if user.address.present?
          parts = user.address.split(',')
          if parts.length >= 4
            user.update_columns(
              street: parts[0].strip,
              postcode: parts[1].strip,
              state: parts[2].strip,
              country: parts[3].strip
            )
          end
        end
      end
    end
  end

  def down
    remove_column :users, :street
    remove_column :users, :postcode
    remove_column :users, :state
    remove_column :users, :country
  end
end 
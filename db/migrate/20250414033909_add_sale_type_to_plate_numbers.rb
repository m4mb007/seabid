class AddSaleTypeToPlateNumbers < ActiveRecord::Migration[8.0]
  def up
    add_column :plate_numbers, :sale_type, :string, default: 'auction'
    
    # Update existing records to have 'auction' as sale_type
    execute "UPDATE plate_numbers SET sale_type = 'auction'"
  end

  def down
    remove_column :plate_numbers, :sale_type
  end
end

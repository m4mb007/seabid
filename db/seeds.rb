# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  admin: true
)

puts "Admin user: admin@example.com / password123 (bidding fee paid)"

# Create regular user
user = User.create!(
  email: 'user@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  admin: false
)

puts "Regular user: user@example.com / password123"

# Create sample plate numbers for auction
auction_plates = [
  { number: 'VIP 1', category: 'prime', starting_price: 50000, current_price: 50000, sale_type: 'auction' },
  { number: 'WXC 888', category: 'popular', starting_price: 3000, current_price: 3000, sale_type: 'auction' },
  { number: 'ABC 123', category: 'main', starting_price: 1000, current_price: 1000, sale_type: 'auction' },
  { number: 'MYR 8888', category: 'prime', starting_price: 30000, current_price: 30000, sale_type: 'auction' },
  { number: 'KL 9999', category: 'popular', starting_price: 5000, current_price: 5000, sale_type: 'auction' }
]

# Create sample plate numbers for direct purchase
direct_plates = [
  { number: 'VIP 2', category: 'prime', starting_price: 45000, current_price: 45000, sale_type: 'direct' },
  { number: 'WXC 999', category: 'popular', starting_price: 2500, current_price: 2500, sale_type: 'direct' },
  { number: 'DEF 456', category: 'main', starting_price: 800, current_price: 800, sale_type: 'direct' },
  { number: 'MYR 7777', category: 'prime', starting_price: 25000, current_price: 25000, sale_type: 'direct' },
  { number: 'KL 8888', category: 'popular', starting_price: 4000, current_price: 4000, sale_type: 'direct' }
]

# Create auction plates
auction_plates.each do |plate_data|
  plate = PlateNumber.create!(
    number: plate_data[:number],
    category: plate_data[:category],
    starting_price: plate_data[:starting_price],
    current_price: plate_data[:current_price],
    sale_type: plate_data[:sale_type],
    status: 'available',
    end_time: 7.days.from_now
  )
  
  # Create some sample bids for auction plates
  if plate.id % 2 == 0 # Add bids to every other plate
    Bid.create!(
      user: admin,
      plate_number: plate,
      amount: plate.starting_price + 500
    )
    plate.update(current_price: plate.starting_price + 500)
  end
end

# Create direct purchase plates
direct_plates.each do |plate_data|
  PlateNumber.create!(
    number: plate_data[:number],
    category: plate_data[:category],
    starting_price: plate_data[:starting_price],
    current_price: plate_data[:current_price],
    sale_type: plate_data[:sale_type],
    status: 'available',
    end_time: 1.year.from_now # Long end time for direct purchase plates
  )
end

puts "Seed data created successfully!"
puts "Created #{PlateNumber.count} plate numbers (#{PlateNumber.auction.count} auction, #{PlateNumber.direct.count} direct purchase)"
puts "Created #{Bid.count} sample bids"

# This file should ensure the existence of records required to run the application in every environment.
# The data can then be loaded with the bin/rails db:seed command or db:setup.

# Clear existing data to avoid duplicates
puts "Cleaning database..."
Bid.delete_all
Payment.delete_all
PlateNumber.delete_all
User.delete_all

# Create admin users
puts "Creating admin users..."
admin1 = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  admin: true,
  first_name: 'Admin',
  last_name: 'User',
  ic_number: 'A12345678',
  seafarer_id: 'SF12345',
  phone_number: '+60123456789',
  street: '123 Admin Street',
  postcode: '50000',
  state: 'Kuala Lumpur',
  country: 'Malaysia'
)

admin2 = User.create!(
  email: 'superadmin@seabid.com',
  password: 'password123',
  password_confirmation: 'password123',
  admin: true,
  first_name: 'Super',
  last_name: 'Admin',
  ic_number: 'A87654321',
  seafarer_id: 'SF67890',
  phone_number: '+60123456788',
  street: '456 Admin Avenue',
  postcode: '50000',
  state: 'Kuala Lumpur',
  country: 'Malaysia'
)

puts "Created admin users:"
puts "  - #{admin1.email} / password123"
puts "  - #{admin2.email} / password123"

# Create regular users
puts "Creating regular users..."
regular_users = [
  { email: 'user1@example.com', bidding_fee_paid: true, first_name: 'John', last_name: 'Doe', ic_number: 'B12345678', seafarer_id: 'SF11111' },
  { email: 'user2@example.com', bidding_fee_paid: true, first_name: 'Jane', last_name: 'Smith', ic_number: 'B23456789', seafarer_id: 'SF22222' },
  { email: 'user3@example.com', bidding_fee_paid: false, first_name: 'Mike', last_name: 'Johnson', ic_number: 'B34567890', seafarer_id: 'SF33333' },
  { email: 'user4@example.com', bidding_fee_paid: true, first_name: 'Sarah', last_name: 'Wilson', ic_number: 'B45678901', seafarer_id: 'SF44444' },
  { email: 'user5@example.com', bidding_fee_paid: false, first_name: 'David', last_name: 'Brown', ic_number: 'B56789012', seafarer_id: 'SF55555' }
]

created_users = regular_users.map do |user_data|
  User.create!(
    email: user_data[:email],
    password: 'password123',
    password_confirmation: 'password123',
    admin: false,
    bidding_fee_paid: user_data[:bidding_fee_paid],
    first_name: user_data[:first_name],
    last_name: user_data[:last_name],
    ic_number: user_data[:ic_number],
    seafarer_id: user_data[:seafarer_id],
    phone_number: '+60' + rand(10**8..10**9-1).to_s,  # Random Malaysian phone number
    street: "#{rand(1..999)} Seafarer Street",
    postcode: rand(10000..99999).to_s,
    state: ['Selangor', 'Penang', 'Johor', 'Sabah', 'Sarawak'].sample,
    country: 'Malaysia'
  )
end

puts "Created regular users:"
created_users.each_with_index do |user, index|
  fee_status = user.bidding_fee_paid? ? "bidding fee paid" : "no bidding fee paid"
  puts "  - #{user.email} / password123 (#{fee_status})"
end

# Create plate numbers for auction
puts "Creating auction plate numbers..."
auction_plates = [
  { number: 'PELAUT 1', category: 'prime', starting_price: 50000, current_price: 50000, sale_type: 'auction', end_time: 7.days.from_now },
  { number: 'PELAUT 888', category: 'popular', starting_price: 3000, current_price: 3000, sale_type: 'auction', end_time: 5.days.from_now },
  { number: 'PELAUT 123', category: 'main', starting_price: 1000, current_price: 1000, sale_type: 'auction', end_time: 3.days.from_now },
  { number: 'PELAUT 8888', category: 'prime', starting_price: 30000, current_price: 30000, sale_type: 'auction', end_time: 6.days.from_now },
  { number: 'PELAUT 9999', category: 'popular', starting_price: 5000, current_price: 5000, sale_type: 'auction', end_time: 4.days.from_now },
  { number: 'PELAUT 7777', category: 'popular', starting_price: 4500, current_price: 4500, sale_type: 'auction', end_time: 8.days.from_now },
  { number: 'PELAUT 555', category: 'main', starting_price: 2500, current_price: 2500, sale_type: 'auction', end_time: 7.days.from_now },
  { number: 'PELAUT 333', category: 'main', starting_price: 1800, current_price: 1800, sale_type: 'auction', end_time: 6.days.from_now }
]

auction_plate_objects = auction_plates.map do |plate_data|
  PlateNumber.create!(
    number: plate_data[:number],
    category: plate_data[:category],
    starting_price: plate_data[:starting_price],
    current_price: plate_data[:current_price],
    sale_type: plate_data[:sale_type],
    status: 'available',
    end_time: plate_data[:end_time]
  )
end

# Create plate numbers for direct purchase
puts "Creating direct sale plate numbers..."
direct_plates = [
  { number: 'PELAUT 2', category: 'prime', starting_price: 45000, current_price: 45000, sale_type: 'direct' },
  { number: 'PELAUT 999', category: 'popular', starting_price: 2500, current_price: 2500, sale_type: 'direct' },
  { number: 'PELAUT 456', category: 'main', starting_price: 800, current_price: 800, sale_type: 'direct' },
  { number: 'PELAUT 7778', category: 'prime', starting_price: 25000, current_price: 25000, sale_type: 'direct' },
  { number: 'PELAUT 8889', category: 'popular', starting_price: 4000, current_price: 4000, sale_type: 'direct' },
  { number: 'PELAUT 5678', category: 'main', starting_price: 1200, current_price: 1200, sale_type: 'direct' },
  { number: 'PELAUT 1234', category: 'main', starting_price: 900, current_price: 900, sale_type: 'direct' },
  { number: 'PELAUT 777', category: 'popular', starting_price: 3500, current_price: 3500, sale_type: 'direct' }
]

direct_plate_objects = direct_plates.map do |plate_data|
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

# Create some bids on auction plates
puts "Creating bids for auction plates..."
eligible_users = created_users.select(&:bidding_fee_paid?)

auction_plate_objects.each_with_index do |plate, index|
  # Create 1-3 bids for each plate to simulate activity
  num_bids = rand(1..3)
  current_price = plate.starting_price
  
  num_bids.times do
    # Pick a random eligible user
    user = eligible_users.sample
    
    # Increase the bid by a random amount (5-15% of current price)
    increase = (current_price * (0.05 + rand * 0.1)).round(2)
    bid_amount = current_price + increase
    
    # Create the bid
    bid = Bid.new(
      user: user,
      plate_number: plate,
      amount: bid_amount
    )
    
    # Skip validation to allow creating multiple bids in sequence
    bid.skip_validation = true
    bid.save!
    
    # Update current price manually
    current_price = bid_amount
  end
  
  # Update the final price of the plate
  plate.update!(current_price: current_price)
end

# Create some completed purchases (both auction and direct)
puts "Creating completed purchases..."

# Completed auction purchase
completed_auction = auction_plate_objects.sample
highest_bid = Bid.where(plate_number: completed_auction).order(amount: :desc).first
if highest_bid
  payment = Payment.new(
    user: highest_bid.user,
    plate_number: completed_auction,
    amount: highest_bid.amount,
    status: 'completed'
  )
  payment.save(validate: false)
  completed_auction.update!(status: 'paid')
end

# Completed direct purchase
completed_direct = direct_plate_objects.sample
direct_buyer = eligible_users.sample
payment = Payment.new(
  user: direct_buyer,
  plate_number: completed_direct,
  amount: completed_direct.current_price,
  status: 'completed'
)
payment.save(validate: false)
completed_direct.update!(status: 'paid')

# Create some processing payments
puts "Creating pending/processing payments..."

# Processing auction payment
processing_auction = auction_plate_objects.sample
highest_bid = Bid.where(plate_number: processing_auction).order(amount: :desc).first
if highest_bid && processing_auction.id != completed_auction.id
  payment = Payment.new(
    user: highest_bid.user,
    plate_number: processing_auction,
    amount: highest_bid.amount,
    status: 'processing'
  )
  payment.save(validate: false)
  processing_auction.update!(status: 'booked')
end

# Processing direct purchase
processing_direct = direct_plate_objects.sample
direct_buyer = eligible_users.sample
if processing_direct.id != completed_direct.id
  payment = Payment.new(
    user: direct_buyer,
    plate_number: processing_direct,
    amount: processing_direct.current_price,
    status: 'processing'
  )
  payment.save(validate: false)
  processing_direct.update!(status: 'booked')
end

# Summary statistics
puts "Seed data created successfully!"
puts "Created #{User.count} users (#{User.where(admin: true).count} admins, #{User.where(admin: false).count} regular users)"
puts "Created #{PlateNumber.count} plate numbers (#{PlateNumber.auction.count} auction, #{PlateNumber.direct.count} direct purchase)"
puts "Created #{Bid.count} bids on auction plates"
puts "Created #{Payment.where(status: 'completed').count} completed payments"
puts "Created #{Payment.where(status: 'processing').count} processing payments"
puts "Total value of completed transactions: RM #{Payment.where(status: 'completed').sum(:amount)}"

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
  password_confirmation: 'password123'
)

# Create regular user
user = User.create!(
  email: 'user@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

# Create plate numbers
categories = %w[prime popular main]

# First create available plates with bids
30.times do |i|
  plate = PlateNumber.create!(
    number: "#{('A'..'Z').to_a.sample}#{rand(1000..9999)}",
    category: categories.sample,
    status: 'available',
    starting_price: rand(1000..5000),
    current_price: rand(5001..10000),
    end_time: rand(2.days.from_now..30.days.from_now)
  )

  # Create some bids
  rand(1..5).times do
    bidder = [admin, user].sample
    amount = plate.current_price + rand(100..1000)
    bid = Bid.new(
      user: bidder,
      plate_number: plate,
      amount: amount
    )
    bid.skip_validation = true
    bid.save!
    plate.update(current_price: amount)
  end
end

# Create some completed plates
10.times do |i|
  plate = PlateNumber.create!(
    number: "#{('A'..'Z').to_a.sample}#{rand(1000..9999)}",
    category: categories.sample,
    status: 'paid',
    starting_price: rand(1000..5000),
    current_price: rand(5001..10000),
    end_time: 1.day.ago
  )

  # Create winning bid
  winner = [admin, user].sample
  bid = Bid.new(
    user: winner,
    plate_number: plate,
    amount: plate.current_price
  )
  bid.skip_validation = true
  bid.save!

  # Create payment
  payment = Payment.new(
    user: winner,
    plate_number: plate,
    amount: plate.current_price,
    status: 'completed'
  )
  payment.skip_validation = true
  payment.save!
end

# Create some booked plates
10.times do |i|
  plate = PlateNumber.create!(
    number: "#{('A'..'Z').to_a.sample}#{rand(1000..9999)}",
    category: categories.sample,
    status: 'booked',
    starting_price: rand(1000..5000),
    current_price: rand(5001..10000),
    end_time: 1.day.ago
  )

  # Create winning bid
  winner = [admin, user].sample
  bid = Bid.new(
    user: winner,
    plate_number: plate,
    amount: plate.current_price
  )
  bid.skip_validation = true
  bid.save!
end

puts "Seed data created successfully!"

FactoryBot.define do
  factory :plate_number do
    number { Faker::Vehicle.unique.license_plate }
    category { ['private', 'commercial'].sample }
    status { 'available' }
    current_price { Faker::Number.between(from: 1000, to: 10000) }
    
    trait :sold do
      status { 'sold' }
    end
    
    trait :reserved do
      status { 'reserved' }
    end
    
    trait :paid do
      status { 'paid' }
    end
  end
end

FactoryBot.define do
  factory :payment do
    user
    amount { 1000 } # RM 10.00
    status { 'pending' }
    stripe_payment_intent_id { "pi_#{SecureRandom.hex(10)}" }
    payment_type { 'bidding_fee' }
    reference_id { 1 }
    
    trait :completed do
      status { 'completed' }
    end
    
    trait :failed do
      status { 'failed' }
    end
    
    trait :plate_number_payment do
      payment_type { 'plate_number' }
      association :plate_number, factory: :plate_number
      reference_id { plate_number.id }
    end
  end
end

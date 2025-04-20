FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    ic_number { Faker::Number.unique.number(digits: 12).to_s }
    phone_number { Faker::PhoneNumber.cell_phone }
    account_type { 'seafarer' }
    
    trait :agent do
      account_type { 'agent' }
      street { Faker::Address.street_address }
      postcode { Faker::Address.zip_code }
      state { Faker::Address.state }
      country { Faker::Address.country }
    end
    
    trait :company do
      account_type { 'company' }
      company_name { Faker::Company.name }
      company_registration_number { Faker::Company.unique.duns_number }
    end
  end
end

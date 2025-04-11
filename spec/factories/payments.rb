FactoryBot.define do
  factory :payment do
    amount { "9.99" }
    status { "MyString" }
    user { nil }
    plate_number { nil }
  end
end

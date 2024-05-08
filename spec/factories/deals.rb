FactoryBot.define do
  factory :deal do
    name { Faker::Company.name }
    status { 'pending' }
    amount { rand(10..1000) }
  end
end
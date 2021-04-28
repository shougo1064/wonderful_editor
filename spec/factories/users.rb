FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { Faker::Internet.password }
    sequence(:email) {|n| "#{n}_#{Faker::Internet.email}" }
  end
end

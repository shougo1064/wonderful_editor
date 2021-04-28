FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.sentence }
    user
    article
  end
end

FactoryBot.define do
  factory :dialog do
    sequence(:title) { |n| "Диалог #{n}" }
  end
end

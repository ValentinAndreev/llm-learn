FactoryBot.define do
  factory :message do
    association :dialog
    role { "user" }
    sequence(:content) { |n| "Сообщение #{n}" }
  end
end

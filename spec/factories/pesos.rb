FactoryBot.define do
  factory :peso do
    data { 1.week.ago.to_date }
    peso { 12.5 }
    observacoes { "Pesagem de rotina" }
    association :pet
    association :usuario, factory: :user
  end
end

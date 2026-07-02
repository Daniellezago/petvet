FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.unique.email }
    password { "senha123" }
    password_confirmation { "senha123" }
    role { "atendente" }
    ativo { true }
  end
end

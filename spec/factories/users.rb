FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "senha123" }
    password_confirmation { "senha123" }
    role { "atendente" }
    ativo { true }
  end

  trait :admin do
    role { "admin" }
  end

  trait :veterinario do
    role { "veterinario" }
  end

  trait :atendente do
    role { "atendente" }
  end
end
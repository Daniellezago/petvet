FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "usuario#{n}@petvet.com" }
    password { "@#PetVet2026!" }
    password_confirmation { "@#PetVet2026!" }
    role { "atendente" }
    ativo { true }

    trait :admin do
      role { "admin" }
    end

    trait :veterinario do
      role { "veterinario" }
      crmv { "CRMV-SP #{rand(10000..99999)}" }
    end

    trait :atendente do
      role { "atendente" }
    end
  end
end

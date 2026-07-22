FactoryBot.define do
  factory :contrato do
    tipo_contrato { :particular }
    data_inicio { Date.current }
    association :tutor

    # o pet precisa pertencer ao MESMO tutor do contrato
    pet { association :pet, tutor: tutor }

    trait :convenio do
      tipo_contrato { :convenio }
      nome_convenio { "PetLove" }
      numero_carteirinha { "CARD-#{rand(10000..99999)}" }
      percentual_cobertura { 80.00 }
    end
  end
end

FactoryBot.define do
  factory :agendamento do
    data_hora { 1.day.from_now.change(hour: 14, min: 0) }
    status { :agendado }
    observacoes { "Consulta de rotina" }
    association :tutor

    # o pet precisa pertencer ao MESMO tutor do agendamento
    pet { association :pet, tutor: tutor }

    association :usuario, factory: :user

    trait :confirmado do
      status { :confirmado }
    end

    trait :cancelado do
      status { :cancelado }
    end
  end
end

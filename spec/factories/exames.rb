FactoryBot.define do
  factory :exame do
    tipo_exame { "Hemograma completo" }
    data { 1.week.ago.to_date }
    resultado { "Todos os valores dentro da normalidade" }
    observacoes { "Sem intercorrências" }
    association :pet
    association :usuario, factory: :user
  end
end

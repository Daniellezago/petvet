FactoryBot.define do
  factory :consulta do
    data { 1.day.ago }
    descricao { "Consulta de rotina" }
    diagnostico { "Animal saudável" }
    tratamento { "Nenhum tratamento necessário" }
    observacoes { "Retorno em 6 meses" }
    association :pet
    association :usuario, factory: :user
  end
end

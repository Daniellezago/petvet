FactoryBot.define do
  factory :vacina do
    nome { "V10" }
    categoria { :vacina }
    data_aplicacao { 1.week.ago.to_date }
    proxima_dose { 1.year.from_now.to_date }
    lote { "L#{rand(1000..9999)}" }
    fabricante { "Zoetis" }
    observacoes { "Sem reações adversas" }
    association :pet
    association :usuario, factory: :user
  end
end

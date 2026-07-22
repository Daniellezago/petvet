FactoryBot.define do
  factory :receituario do
    tipo_receituario { :simples }
    medicamento { "Amoxicilina 250mg" }
    posologia { "1 comprimido a cada 12 horas, por via oral" }
    duracao_tratamento { "7 dias" }
    observacoes { "Administrar com alimento" }
    data_emissao { Date.current }
    association :pet
    association :usuario, factory: [ :user, :veterinario ]
    crmv_responsavel { usuario.crmv }

    trait :controle_especial do
      tipo_receituario { :controle_especial }
      medicamento { "Tramadol 50mg" }
    end
  end
end

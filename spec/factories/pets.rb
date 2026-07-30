FactoryBot.define do
  factory :pet do
    nome { Faker::Creature::Dog.name }
    especie { "Cachorro" }
    raca { Faker::Creature::Dog.breed }
    sexo { %i[macho femea].sample }
    data_nascimento { Faker::Date.birthday(min_age: 0, max_age: 15) }
    peso_atual { Faker::Number.decimal(l_digits: 1, r_digits: 2) }
    association :tutor
    castrado { false }
    porte { :medio }
    cor { "Caramelo" }

    trait :gato do
      especie { "Gato" }
      nome { Faker::Creature::Cat.name }
      raca { Faker::Creature::Cat.breed }
    end
  end
end

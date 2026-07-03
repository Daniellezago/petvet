FactoryBot.define do
  factory :tutor do
    nome { Faker::Name.name }
    email { Faker::Internet.unique.email }
    telefone { Faker::PhoneNumber.phone_number }
    cpf { Faker::CPF.numeric }
    endereco { Faker::Address.full_address }
    ativo { true }
  end
end
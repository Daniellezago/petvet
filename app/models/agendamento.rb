class Agendamento < ApplicationRecord
  belongs_to :tutor
  belongs_to :pet
  belongs_to :usuario, class_name: "User"

  enum :status, { agendado: 0, confirmado: 1, realizado: 2, cancelado: 3 }, default: :agendado

  validates :data_hora, presence: true

  validate :pet_deve_pertencer_ao_tutor

  private

  def pet_deve_pertencer_ao_tutor
    return if pet.blank? || tutor.blank?

    if pet.tutor_id != tutor_id
      errors.add(:pet, "deve pertencer ao tutor informado")
    end
  end
end
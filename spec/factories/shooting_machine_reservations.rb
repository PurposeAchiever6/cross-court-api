# == Schema Information
#
# Table name: shooting_machine_reservations
#
#  id                       :bigint           not null, primary key
#  shooting_machine_id      :bigint
#  user_session_id          :bigint
#  status                   :integer          default("reserved")
#  charge_payment_intent_id :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  error_on_charge          :string
#
# Indexes
#
#  index_shooting_machine_reservations_on_shooting_machine_id  (shooting_machine_id)
#  index_shooting_machine_reservations_on_user_session_id      (user_session_id)
#

FactoryBot.define do
  factory :shooting_machine_reservation do
    status { :reserved }
    charge_payment_intent_id { nil }
    shooting_machine
    user_session
  end
end

# == Schema Information
#
# Table name: shooting_machine_reservations
#
#  id                       :integer          not null, primary key
#  shooting_machine_id      :integer
#  user_session_id          :integer
#  status                   :integer          default("reserved")
#  charge_payment_intent_id :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_shooting_machine_reservations_on_shooting_machine_id  (shooting_machine_id)
#  index_shooting_machine_reservations_on_user_session_id      (user_session_id)
#

class ShootingMachineReservation < ApplicationRecord
  belongs_to :user_session
  belongs_to :shooting_machine

  delegate :user, to: :user_session
  delegate :start_time_str, :end_time_str, to: :shooting_machine

  enum status: { reserved: 0, canceled: 1 }

  scope :by_date, ->(date) { joins(:user_session).where(user_sessions: { date: date }) }
end

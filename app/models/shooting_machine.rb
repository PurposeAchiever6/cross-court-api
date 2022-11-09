# == Schema Information
#
# Table name: shooting_machines
#
#  id         :integer          not null, primary key
#  session_id :integer
#  price      :float            default(15.0)
#  start_time :time
#  end_time   :time
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_shooting_machines_on_session_id  (session_id)
#

class ShootingMachine < ApplicationRecord
  validates :start_time, :end_time, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :session
  has_many :shooting_machine_reservations, dependent: :nullify

  def start_time
    start_time_value = attributes['start_time']

    return unless start_time_value

    "#{start_time_value.hour}:#{start_time_value.min}"
  end

  def end_time
    end_time_value = attributes['end_time']

    return unless end_time_value

    "#{end_time_value.hour}:#{end_time_value.min}"
  end

  def reserved?(date)
    shooting_machine_reservations.reserved.by_date(date).exists?
  end
end

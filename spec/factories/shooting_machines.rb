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

FactoryBot.define do
  factory :shooting_machine do
    price { rand(10..20) }
    start_time { '14:00' }
    end_time { '14:30' }
    session
  end
end

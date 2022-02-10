# == Schema Information
#
# Table name: session_exceptions
#
#  id         :integer          not null, primary key
#  session_id :integer          not null
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_session_exceptions_on_date_and_session_id  (date,session_id)
#  index_session_exceptions_on_session_id           (session_id)
#

FactoryBot.define do
  factory :session_exception do
    session
    date { 10.days.from_now }
  end
end

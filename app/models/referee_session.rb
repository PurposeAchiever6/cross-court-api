# == Schema Information
#
# Table name: employee_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer
#  date       :date             not null
#  state      :integer          default("unconfirmed"), not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_employee_sessions_on_session_id  (session_id)
#  index_employee_sessions_on_user_id     (user_id)
#

class RefereeSession < EmployeeSession
  alias_attribute :referee, :user
end

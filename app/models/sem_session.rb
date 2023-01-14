# == Schema Information
#
# Table name: employee_sessions
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  session_id :bigint
#  date       :date             not null
#  state      :integer          default("unconfirmed"), not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_employee_sessions_on_session_id  (session_id)
#  index_employee_sessions_on_type        (type)
#  index_employee_sessions_on_user_id     (user_id)
#

class SemSession < EmployeeSession
  alias_attribute :sem, :user
end

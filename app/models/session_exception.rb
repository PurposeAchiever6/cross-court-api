# == Schema Information
#
# Table name: session_exceptions
#
#  id         :integer          not null, primary key
#  session_id :integer          not null
#  date       :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_session_exceptions_on_date_and_session_id  (date,session_id)
#  index_session_exceptions_on_session_id           (session_id)
#

class SessionException < ApplicationRecord
  belongs_to :session

  validates :date, presence: true, uniqueness: { scope: :session_id }
end

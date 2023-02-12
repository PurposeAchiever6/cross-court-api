# == Schema Information
#
# Table name: session_exceptions
#
#  id         :bigint           not null, primary key
#  session_id :bigint           not null
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_session_exceptions_on_date_and_session_id  (date,session_id)
#  index_session_exceptions_on_session_id           (session_id)
#

class SessionException < ApplicationRecord
  has_paper_trail

  belongs_to :session

  validates :date, presence: true, uniqueness: { scope: :session_id }
end

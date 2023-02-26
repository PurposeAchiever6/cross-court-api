# == Schema Information
#
# Table name: session_surveys
#
#  id              :bigint           not null, primary key
#  rate            :integer
#  feedback        :text
#  user_id         :bigint
#  user_session_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_session_surveys_on_user_id          (user_id)
#  index_session_surveys_on_user_session_id  (user_session_id)
#
class SessionSurvey < ApplicationRecord
  belongs_to :user
  belongs_to :user_session
end

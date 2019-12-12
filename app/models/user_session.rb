# == Schema Information
#
# Table name: user_sessions
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  session_id          :integer          not null
#  state               :integer          default("reserved"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  date                :date             not null
#  sms_reminder_sent   :boolean          default(FALSE), not null
#  email_reminder_sent :boolean          default(FALSE), not null
#
# Indexes
#
#  index_user_sessions_on_date_and_user_id_and_session_id  (date,user_id,session_id) UNIQUE
#  index_user_sessions_on_email_reminder_sent              (email_reminder_sent)
#  index_user_sessions_on_session_id                       (session_id)
#  index_user_sessions_on_sms_reminder_sent                (sms_reminder_sent)
#  index_user_sessions_on_user_id                          (user_id)
#

class UserSession < ApplicationRecord
  enum state: { reserved: 0, canceled: 1, confirmed: 2 }

  belongs_to :user
  belongs_to :session

  validates :state, :date, presence: true
  validates :date, uniqueness: { scope: %i[session_id user_id] }

  delegate :time, to: :session, prefix: true
  delegate :phone_number, :name, :email, to: :user, prefix: true

  scope :email_not_sent, -> { where(email_reminder_sent: false) }
  scope :sms_not_sent, -> { where(sms_reminder_sent: false) }
  scope :past, (lambda do
    joins(:session).where('date < :date OR (date = :date AND time::time < :current_time )',
                          date: Date.current,
                          current_time: Time.current.strftime(Session::TIME_FORMAT),
                          date_format: Session::TIME_FORMAT)
  end)
  scope :future, (lambda do
    joins(:session).where('date > :date OR (date = :date AND time::time > :current_time )',
                          date: Date.current,
                          current_time: Time.current.strftime(Session::TIME_FORMAT),
                          date_format: Session::TIME_FORMAT)
  end)
end

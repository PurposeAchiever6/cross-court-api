# == Schema Information
#
# Table name: session_guests
#
#  id              :integer          not null, primary key
#  first_name      :string           not null
#  last_name       :string           not null
#  phone_number    :string           not null
#  email           :string           not null
#  access_code     :string           not null
#  state           :integer          default("reserved"), not null
#  user_session_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_session_guests_on_user_session_id  (user_session_id)
#

class SessionGuest < ApplicationRecord
  enum state: { reserved: 0, canceled: 1, confirmed: 2 }

  validates :first_name, :last_name, :phone_number, :email, :access_code, :state, presence: true

  belongs_to :user_session

  before_validation :create_access_code

  scope :by_date, ->(date) { joins(:user_session).where(user_sessions: { date: }) }
  scope :for_phone, ->(phone_number) { where(phone_number:) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_access_code
    return if access_code.present?

    self.access_code = "#{first_name.first}#{last_name.first}#{SecureRandom.hex(2)}".upcase
  end
end

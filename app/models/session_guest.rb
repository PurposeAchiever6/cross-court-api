# == Schema Information
#
# Table name: session_guests
#
#  id              :bigint           not null, primary key
#  first_name      :string           not null
#  last_name       :string           not null
#  phone_number    :string           not null
#  email           :string           not null
#  access_code     :string           not null
#  state           :integer          default("reserved"), not null
#  user_session_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  checked_in      :boolean          default(FALSE)
#  assigned_team   :string
#
# Indexes
#
#  index_session_guests_on_user_session_id  (user_session_id)
#

class SessionGuest < ApplicationRecord
  enum state: { reserved: 0, canceled: 1, confirmed: 2, no_show: 3 }

  validates :first_name, :last_name, :phone_number, :email, :access_code, :state, presence: true

  belongs_to :user_session

  before_validation :create_access_code
  before_save :normalize_phone_number

  scope :by_date, ->(date) { joins(:user_session).where(user_sessions: { date: }) }
  scope :for_phone, ->(phone_number) { where(phone_number: phone_number_normalized(phone_number)) }
  scope :sorted_by_full_name, -> { order('LOWER(first_name) ASC, LOWER(last_name) ASC') }
  scope :not_checked_in, -> { where(checked_in: false) }

  scope :for_yesterday, (lambda do
    joins(user_session: { session: :location })
      .where('date = (current_timestamp at time zone locations.time_zone)::date - 1')
  end)

  def self.phone_number_normalized(phone_number)
    phone_number.scan(/\d/).join
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_access_code
    return if access_code.present?

    self.access_code = "#{first_name.first}#{last_name.first}#{SecureRandom.hex(2)}".upcase
  end

  def first_time?
    SessionGuest.where(phone_number:).count == 1
  end

  def user
    User.where(email:).or(User.where(phone_number:)).first
  end

  private

  def normalize_phone_number
    return if phone_number.blank?

    self.phone_number = self.class.phone_number_normalized(phone_number)
  end
end

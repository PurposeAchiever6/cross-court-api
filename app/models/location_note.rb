# == Schema Information
#
# Table name: location_notes
#
#  id            :bigint           not null, primary key
#  notes         :text
#  date          :date
#  admin_user_id :bigint
#  location_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_location_notes_on_admin_user_id  (admin_user_id)
#  index_location_notes_on_location_id    (location_id)
#

class LocationNote < ApplicationRecord
  belongs_to :location
  belongs_to :admin_user

  validates :notes, presence: true
  validates :date, presence: true
  validate :date_not_in_the_past

  scope :for_date, ->(date) { where(date:) }

  private

  def date_not_in_the_past
    errors.add(:date, "can't be in the past") if date&.past?
  end
end

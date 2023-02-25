# == Schema Information
#
# Table name: user_sessions
#
#  id                              :bigint           not null, primary key
#  user_id                         :bigint           not null
#  session_id                      :bigint           not null
#  state                           :integer          default("reserved"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  date                            :date             not null
#  checked_in                      :boolean          default(FALSE), not null
#  is_free_session                 :boolean          default(FALSE), not null
#  free_session_payment_intent     :string
#  credit_reimbursed               :boolean          default(FALSE), not null
#  referral_id                     :bigint
#  jersey_rental                   :boolean          default(FALSE)
#  jersey_rental_payment_intent_id :string
#  assigned_team                   :string
#  no_show_up_fee_charged          :boolean          default(FALSE)
#  reminder_sent_at                :datetime
#  first_session                   :boolean          default(FALSE)
#  credit_used_type                :integer
#  goal                            :string
#  scouting                        :boolean          default(FALSE)
#  towel_rental                    :boolean          default(FALSE)
#  towel_rental_payment_intent_id  :string
#
# Indexes
#
#  index_user_sessions_on_referral_id  (referral_id)
#  index_user_sessions_on_session_id   (session_id)
#  index_user_sessions_on_user_id      (user_id)
#

require 'rails_helper'

describe UserSession do
  describe 'validations' do
    subject { build :user_session }

    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:date) }
    it {
      is_expected.to define_enum_for(:state).with_values(%i[reserved canceled confirmed no_show])
    }
  end

  describe 'associations' do
    subject { build :user_session }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end

  describe 'date_when_format' do
    let!(:location) { create(:location) }
    let!(:session) { create(:session, location:) }
    let!(:user_session) { create(:user_session, date:, session:) }

    let(:time_zone) { location.time_zone }
    let(:date) { Time.current.in_time_zone(location.time_zone).to_date }

    subject { user_session.date_when_format }

    it { is_expected.to eq('today') }

    context 'when the date of the session is tomorrow' do
      let(:date) { Time.current.in_time_zone(time_zone).to_date + 1.day }

      it { is_expected.to eq('tomorrow') }
    end

    context 'when the date of the session is not today or tomorrow' do
      let(:date) { Date.parse('2022-01-01') }

      it { is_expected.to eq('Saturday January 1') }
    end
  end

  describe 'late_arrival?' do
    let!(:session) { create(:session, :daily, location:, time: session_time) }
    let!(:user_session) { create(:user_session, session:, date:) }
    let!(:location) { create(:location, late_arrival_minutes:) }

    let(:checked_in_time) { ActiveSupport::TimeZone[location.time_zone].parse('12:20:00') }
    let(:session_time) { Time.parse('12:00:00 UTC') }
    let(:date) { Time.current.in_time_zone(location.time_zone).to_date }
    let(:late_arrival_minutes) { 30 }

    subject { user_session.late_arrival?(checked_in_time) }

    it { is_expected.to eq(false) }

    context 'when the user checked in late' do
      let(:checked_in_time) { ActiveSupport::TimeZone[location.time_zone].parse('12:31:00') }

      it { is_expected.to eq(true) }
    end

    context 'when the location late_arrival_minutes is zero' do
      let(:late_arrival_minutes) { 0 }

      it { is_expected.to eq(true) }
    end
  end
end

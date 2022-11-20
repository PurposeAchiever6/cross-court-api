# == Schema Information
#
# Table name: user_sessions
#
#  id                              :integer          not null, primary key
#  user_id                         :integer          not null
#  session_id                      :integer          not null
#  state                           :integer          default("reserved"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  date                            :date             not null
#  checked_in                      :boolean          default(FALSE), not null
#  is_free_session                 :boolean          default(FALSE), not null
#  free_session_payment_intent     :string
#  credit_reimbursed               :boolean          default(FALSE), not null
#  referral_id                     :integer
#  jersey_rental                   :boolean          default(FALSE)
#  jersey_rental_payment_intent_id :string
#  assigned_team                   :string
#  no_show_up_fee_charged          :boolean          default(FALSE)
#  reminder_sent_at                :datetime
#  first_session                   :boolean          default(FALSE)
#  credit_used_type                :integer
#  goal                            :string
#  scouting                        :boolean          default(FALSE)
#
# Indexes
#
#  index_user_sessions_on_session_id  (session_id)
#  index_user_sessions_on_user_id     (user_id)
#

require 'rails_helper'

describe UserSession do
  describe 'validations' do
    subject { build :user_session }

    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to define_enum_for(:state).with_values(%i[reserved canceled confirmed]) }
  end

  describe 'associations' do
    subject { build :user_session }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end

  describe 'date_when_format' do
    let!(:location) { create(:location) }
    let!(:session) { create(:session, location: location) }
    let!(:user_session) { create(:user_session, date: date, session: session) }

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
end

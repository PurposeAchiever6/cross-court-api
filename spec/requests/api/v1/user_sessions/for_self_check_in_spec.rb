require 'rails_helper'

describe 'GET api/v1/user_sessions/for_self_check_in' do
  let(:user) { create(:user) }
  let(:time_zone) { 'America/Los_Angeles' }
  let(:los_angeles_time) { Time.zone.local_to_utc(Time.current.in_time_zone(time_zone)) }
  let(:location) { create(:location, time_zone:) }
  let(:location_id) { location.id }
  let(:date) { Date.current }
  let(:checked_in) { false }

  let(:session_1) { create(:session, time: los_angeles_time - 1.hour, location:) }
  let(:session_2) { create(:session, time: los_angeles_time + 30.minutes, location:) }
  let(:session_3) { create(:session, time: los_angeles_time + 1.hour, location:) }

  let!(:user_session_1) { create(:user_session, session: session_1, user:, date:, checked_in:) }
  let!(:user_session_2) { create(:user_session, session: session_2, user:, date:, checked_in:) }
  let!(:user_session_3) { create(:user_session, session: session_3, user:, date:, checked_in:) }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  before { Timecop.freeze }

  after { Timecop.return }

  subject do
    get for_self_check_in_api_v1_user_sessions_path,
        headers: auth_headers,
        params: { location_id: },
        as: :json
    response
  end

  it { is_expected.to be_successful }

  it 'returns the user_sessions in the next 2 hours' do
    expect(response_body[:user_sessions].count).to eq(2)
    expect(response_body[:user_sessions].first[:id]).to eq(user_session_2.id)
    expect(response_body[:user_sessions].second[:id]).to eq(user_session_3.id)
  end

  context 'when the user has not reserved any session' do
    before { UserSession.destroy_all }

    it { is_expected.to be_successful }

    it { expect(response_body[:user_sessions].count).to eq(0) }
  end

  context 'when the sessions have been checked_in' do
    let(:checked_in) { true }

    it { is_expected.to be_successful }

    it { expect(response_body[:user_sessions].count).to eq(0) }
  end

  context 'when the sessions are for another location' do
    let(:location_2) { create(:location, time_zone:) }
    let(:location_id) { location_2.id }

    it { is_expected.to be_successful }

    it { expect(response_body[:user_sessions].count).to eq(0) }
  end

  context 'when the sessions are for another day' do
    let(:date) { Date.current + 1.day }

    it { is_expected.to be_successful }

    it { expect(response_body[:user_sessions].count).to eq(0) }
  end
end

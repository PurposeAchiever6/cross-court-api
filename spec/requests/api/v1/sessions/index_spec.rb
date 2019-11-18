require 'rails_helper'

describe 'GET api/v1/sessions', type: :request do
  let(:user)      { create(:user) }
  let(:location)  { create(:location) }
  let(:from_date) { Time.current.beginning_of_week.strftime(Session::DATE_FORMAT) }

  subject do
    get api_v1_sessions_path(location_id: location.id, from_date: from_date),
        headers: auth_headers,
        as: :json
  end

  context 'when the session is a one time only' do
    let!(:session) { create(:session, location: location) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns the sessions for this week' do
      subject
      expect(json[:sessions].count).to eq(1)
    end
  end

  context 'when the session is repeted everyday' do
    let!(:session) { create(:session, :daily, location: location) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns the sessions for this week' do
      subject
      expect(json[:sessions].count).to eq(7)
    end
  end

  context 'when there are sessions for multiple locations' do
    let(:location_2) { create(:location) }
    let!(:session)   { create(:session, location: location) }
    let!(:session_2) { create(:session, location: location_2) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns only one session' do
      subject
      expect(json[:sessions].count).to eq(1)
    end

    it 'returns the session for the location' do
      subject
      expect(json[:sessions][0][:id]).to eq(session.id)
    end
  end
end

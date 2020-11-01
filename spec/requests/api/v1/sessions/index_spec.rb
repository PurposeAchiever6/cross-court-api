require 'rails_helper'

describe 'GET api/v1/sessions', type: :request do
  let(:user)              { create(:user) }
  let(:los_angeles_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
  let(:beginning_of_week) { los_angeles_time.beginning_of_week }
  let(:from_date)         { beginning_of_week.strftime(Session::DATE_FORMAT) }
  let(:params)            { { from_date: from_date } }
  let(:today)             { los_angeles_time.to_date.to_s }

  subject do
    get api_v1_sessions_path(params),
        headers: auth_headers,
        as: :json
  end

  context 'when the session is a one time only' do
    let!(:session) { create(:session) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns the sessions for this week' do
      subject
      expect(json[:sessions].count).to eq(1)
    end

    it 'returns the number of spots left' do
      subject
      expect(json[:sessions][0][:spots_left]).to eq(Session::MAX_CAPACITY)
    end

    context 'when the user has a reservation for today' do
      let!(:user_session) { create(:user_session, user: user, session: session, date: today) }

      it 'returns reserved in true' do
        subject
        expect(json[:sessions][0][:reserved]).to be true
      end
    end

    context 'when the session is full' do
      let!(:user_session) { create_list(:user_session, 15, session: session, date: today) }

      it 'retruns full on true' do
        subject
        expect(json[:sessions][0][:full]).to be true
      end
    end
  end

  context 'when the session is repeted everyday' do
    let!(:session) { create(:session, :daily, start_time: Time.current.beginning_of_week) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns the sessions for this week' do
      subject
      expect(json[:sessions].count).to eq(7)
    end

    it 'returns reserved in false' do
      subject
      expect(json[:sessions][0][:reserved]).to be false
    end

    it 'returns full on false' do
      subject
      expect(json[:sessions][0][:full]).to be false
    end

    context 'when the session has an end_time' do
      let!(:session) do
        create(:session, :daily, start_time: Time.current.beginning_of_week,
                                 end_time: beginning_of_week + 2.days)
      end

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it 'returns the sessions until the end_time' do
        subject
        expect(json[:sessions].count).to eq(3)
      end
    end
  end

  context 'when there are sessions for multiple locations' do
    let(:location)   { create(:location) }
    let(:location_2) { create(:location) }
    let!(:session)   { create(:session, location: location) }
    let!(:session_2) { create(:session, location: location_2) }

    before do
      params[:location_id] = location.id
    end

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

  context 'when the session is in the past' do
    let!(:session) { create(:session, :daily, time: los_angeles_time - 1.minute) }

    it 'returns past in true' do
      subject
      expect(json[:sessions][0][:past]).to be true
    end
  end
end

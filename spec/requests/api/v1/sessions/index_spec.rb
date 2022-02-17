require 'rails_helper'

describe 'GET api/v1/sessions', type: :request do
  let(:user_private_access) { false }
  let(:user) { create(:user, private_access: user_private_access) }
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let(:beginning_of_week) { los_angeles_time.beginning_of_week }
  let(:from_date) { beginning_of_week.strftime(Session::DATE_FORMAT) }
  let(:params) { { from_date: from_date } }
  let(:today) { los_angeles_time.to_date.to_s }
  let(:request_headers) { auth_headers }

  subject do
    get api_v1_sessions_path(params),
        headers: request_headers,
        as: :json
  end

  context 'when the session is a one time only' do
    let(:is_private) { false }
    let!(:session) { create(:session, time: los_angeles_time + 1.hour, is_private: is_private) }

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

    it 'returns that user is not on the waitlist' do
      subject
      expect(json[:sessions][0][:on_waitlist]).to eq(false)
    end

    context 'when the session is full' do
      let!(:user_session) { create_list(:user_session, 15, session: session, date: today) }

      it 'retruns full on true' do
        subject
        expect(json[:sessions][0][:full]).to be true
      end
    end

    context 'when the session is private' do
      let(:is_private) { true }

      it 'returns no session' do
        subject
        expect(json[:sessions].count).to eq(0)
      end

      context 'when not logged in user' do
        let(:request_headers) { nil }

        it 'returns no session' do
          subject
          expect(json[:sessions].count).to eq(0)
        end
      end

      context 'when user has private access' do
        let(:user_private_access) { true }

        it 'returns the expected session' do
          subject
          expect(json[:sessions].count).to eq(1)
        end
      end
    end

    context 'when user is on waitlist' do
      let!(:user_session_waitlist) do
        create(
          :user_session_waitlist,
          session: session,
          user: user,
          date: session.start_time
        )
      end

      it 'returns that user is on the waitlist' do
        subject
        expect(json[:sessions][0][:on_waitlist]).to eq(true)
      end
    end
  end

  context 'when the session is repeted everyday' do
    let!(:session) { create(:session, :daily, start_time: los_angeles_time.beginning_of_week) }

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
        create(:session, :daily, start_time: los_angeles_time.beginning_of_week,
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

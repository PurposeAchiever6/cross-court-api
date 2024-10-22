require 'rails_helper'

describe 'GET api/v1/locations/:location_id/sessions/:id', type: :request do
  let(:user)     { create(:user) }
  let(:location) { create(:location) }
  let!(:session) { create(:session, location:, time: la_time + 1.hour) }

  let!(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
  let!(:today)    { la_time.to_date }
  let!(:tomorrow) { today.tomorrow }

  before :each do
    host! ENV.fetch('SERVER_URL')
  end

  subject do
    get api_v1_session_path(location_id: location.id, id: session.id, date: today),
        headers: auth_headers,
        as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it "returns the session's data" do
    subject

    expect(json[:session]).to include_json(
      id: session.id,
      start_time: session.start_time.iso8601,
      time: session.time.iso8601,
      full: false,
      past: false,
      on_waitlist: false
    )
  end

  context 'when user is on the waitlist' do
    let(:state) { :pending }

    let!(:user_session_waitlist) do
      create(:user_session_waitlist, session:, user:, date: today, state:)
    end

    it "returns the user is on the session's waitlist" do
      subject
      expect(json[:session][:on_waitlist]).to eq(true)
    end

    context 'when the user has already made it off the waitlist' do
      let(:state) { :success }

      it "returns the user is on the session's waitlist" do
        subject
        expect(json[:session][:on_waitlist]).to eq(false)
      end
    end
  end

  context 'when the session has employees assigned' do
    let(:referee)      { create(:user, :referee, :with_image) }
    let(:sem)          { create(:user, :referee, :with_image) }
    let!(:sem_session) { create(:sem_session, session:, user: sem, date: today) }
    let!(:referee_session) do
      create(:referee_session, session:, user: referee, date: today)
    end

    it 'returns referee information' do
      subject
      expect(json[:session][:referee]).to include_json(
        full_name: referee.full_name,
        image_url: polymorphic_url(referee.image)
      )
    end

    it 'returns sem information' do
      subject
      expect(json[:session][:sem]).to include_json(
        full_name: sem.full_name,
        image_url: polymorphic_url(sem.image)
      )
    end
  end

  context 'when the user has a reservation for the same day' do
    let!(:user_session) { create(:user_session, user:, session:, date: today) }

    it 'returns an user_session' do
      subject
      expect(json[:session][:user_session]).to include_json(
        id: user_session.id,
        date: user_session.date.iso8601,
        state: user_session.state,
        in_cancellation_time: user_session.in_cancellation_time?,
        in_confirmation_time: user_session.in_confirmation_time?
      )
    end

    it 'returns the number of spots left' do
      subject
      expect(json[:session][:spots_left]).to eq(session.spots_left(today))
    end
  end

  context 'when the user has a reservation for another day' do
    let!(:user_session) { create(:user_session, user:, session:, date: tomorrow) }

    subject do
      get api_v1_session_path(location_id: location.id, id: session.id, date: today),
          headers: auth_headers,
          as: :json
    end

    it "doesn't return an user_session" do
      subject
      expect(json[:session][:user_session]).to be nil
    end
  end

  context 'when the session is in the past' do
    let(:lost_angeles_time) { Time.current.in_time_zone('America/Los_Angeles') }
    let(:session) { create(:session, time: Time.zone.local_to_utc(lost_angeles_time) - 1.minute) }

    it 'returns past in true' do
      subject
      expect(json[:session][:past]).to be true
    end
  end

  context 'when the user is not logged in' do
    subject do
      get api_v1_session_path(location_id: location.id, id: session.id, date: tomorrow),
          as: :json
    end

    it "doesn't return an user_session" do
      subject
      expect(json[:session][:user_session]).to be nil
    end
  end

  context 'when the session is full' do
    let!(:user_sessions) { create_list(:user_session, 15, session:, date: today) }

    it 'returns full on true' do
      subject
      expect(json[:session][:full]).to be true
    end
  end
end

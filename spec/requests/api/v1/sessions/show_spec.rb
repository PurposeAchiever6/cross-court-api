require 'rails_helper'

describe 'GET api/v1/locations/:location_id/sessions/:id', type: :request do
  let(:user)     { create(:user) }
  let(:location) { create(:location) }
  let!(:session) { create(:session, location: location) }
  let(:today)    { Date.current.to_s }

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
      time: session.time.iso8601
    )
  end

  context 'when the session has employees assigned' do
    let(:referee)      { create(:user, :referee, :with_image) }
    let(:sem)          { create(:user, :referee, :with_image) }
    let!(:sem_session) { create(:sem_session, session: session, user: sem, date: today) }
    let!(:referee_session) do
      create(:referee_session, session: session, user: referee, date: today)
    end

    it 'returns referee information' do
      subject
      expect(json[:session][:referee]).to include_json(
        name: referee.name,
        image_url: polymorphic_url(referee.image)
      )
    end

    it 'returns sem information' do
      subject
      expect(json[:session][:sem]).to include_json(
        name: sem.name,
        image_url: polymorphic_url(sem.image)
      )
    end
  end
end

require 'rails_helper'

describe 'GET api/v1/locations/:location_id/sessions/:id', type: :request do
  let(:user)     { create(:user) }
  let(:location) { create(:location) }
  let!(:session) { create(:session, location: location) }

  subject do
    get api_v1_location_session_path(location_id: location.id, id: session.id),
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
end

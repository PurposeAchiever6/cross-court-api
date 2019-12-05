require 'rails_helper'

describe 'GET api/v1/user_sessions' do
  let!(:user) { create(:user) }

  subject do
    get api_v1_user_sessions_path, headers: auth_headers, as: :json
  end

  describe 'when the user has not resereved any session' do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns no user_sessions' do
      subject
      expect(json[:user_sessions].count).to eq(0)
    end
  end

  describe 'when the user has already been in sessions' do
    let!(:user_sessions) { create_list(:user_session, 5, user: user) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns 5 user_sessions' do
      subject
      expect(json[:user_sessions].count).to eq(5)
    end
  end
end

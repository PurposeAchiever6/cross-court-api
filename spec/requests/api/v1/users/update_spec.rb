require 'rails_helper'

describe 'PUT api/v1/user/', type: :request do
  let(:user)             { create(:user) }
  let(:api_v1_user_path) { '/api/v1/user' }

  context 'with valid params' do
    let(:params) { { user: { first_name: 'new first_name' } } }

    it 'returns success' do
      put api_v1_user_path, params: params, headers: auth_headers, as: :json
      expect(response).to have_http_status(:success)
    end

    it 'updates the user' do
      put api_v1_user_path, params: params, headers: auth_headers, as: :json
      expect(user.reload.first_name).to eq(params[:user][:first_name])
    end

    it 'returns the user' do
      put api_v1_user_path, params: params, headers: auth_headers, as: :json

      expect(json[:user][:id]).to eq user.id
    end
  end

  context 'with missing params' do
    it 'returns the missing params error' do
      put api_v1_user_path, params: {}, headers: auth_headers, as: :json
      expect(json[:error]).to eq 'A required param is missing'
    end
  end
end

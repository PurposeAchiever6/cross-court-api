require 'rails_helper'

describe 'GET api/v1/legal/:title' do
  let!(:terms_and_conditions) { create(:legal, title: 'terms_and_conditions') }

  before { get api_v1_legal_path(title), as: :json }

  context 'with valid params' do
    let(:title) { terms_and_conditions.title }

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns the legal text' do
      expect(json[:text]).to eq(terms_and_conditions.text)
    end
  end

  context 'with invalid params' do
    let(:title) { 'invalid' }

    it 'returns bad request' do
      expect(response).to have_http_status(:bad_request)
    end
  end
end

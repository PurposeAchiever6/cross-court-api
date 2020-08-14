require 'rails_helper'

describe 'GET api/v1/locations' do
  let(:user)       { create(:user) }
  let!(:locations) { create_list(:location, 5) }
  let(:expected_response) do
    locations.map do |location|
      {
        id: location.id,
        name: location.name,
        address: location.address
      }
    end
  end

  before do
    get api_v1_locations_path, headers: auth_headers, as: :json
  end

  it 'returns all locations' do
    expect(json[:locations].count).to eq(5)
  end

  it 'returns location information' do
    expect(json[:locations]).to include_json(expected_response)
  end
end

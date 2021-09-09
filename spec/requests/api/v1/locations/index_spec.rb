require 'rails_helper'

describe 'GET api/v1/locations' do
  let(:user)       { create(:user) }
  let!(:locations) { create_list(:location, 5) }
  let(:expected_response) do
    locations.map do |location|
      {
        id: location.id,
        name: location.name,
        address: location.address,
        city: location.city,
        zipcode: location.zipcode,
        description: location.description
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
    id = json[:locations].first[:id]
    response_item = expected_response.select { |location| location[:id] == id }

    expect(json[:locations].first).to include_json(response_item.first)
  end
end

require 'rails_helper'

describe 'GET api/v1/goals' do
  let!(:goals) { create_list(:goal, 5) }

  let(:expected_response) do
    goals.map do |goal|
      {
        id: goal.id,
        category: goal.category,
        description: goal.description
      }
    end
  end

  before do
    get api_v1_goals_path, headers: nil, as: :json
  end

  it 'returns all goals' do
    expect(json[:goals].count).to eq(5)
  end

  it 'returns goals information' do
    id = json[:goals].first[:id]
    response_item = expected_response.select { |goal| goal[:id] == id }

    expect(json[:goals].first).to include_json(response_item.first)
  end
end

require 'rails_helper'

describe Api::V1::DeviseSessionsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/api/v1/users/').to route_to('api/v1/registrations#create')
    end
  end
end

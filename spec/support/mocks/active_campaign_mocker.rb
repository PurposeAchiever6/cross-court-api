# frozen_string_literal: true

class ActiveCampaignMocker
  attr_reader :base_url, :options

  def initialize
    @base_url = ENV['ACTIVE_CAMPAING_API_URL']
  end

  def mock
    contact_fields
    deal_fields
    deal_stages
    create_deal
    create_update_contact
  end

  def contact_fields
    WebMock.stub_request(:get, "#{base_url}/api/3/fields").with(
      body: {},
      headers: default_headers
    ).to_return(
      status: 200,
      body: contact_fields_response
    )
  end

  def deal_fields
    WebMock.stub_request(:get, "#{base_url}/api/3/dealCustomFieldMeta").with(
      body: {},
      headers: default_headers
    ).to_return(
      status: 200,
      body: deal_fields_response
    )
  end

  def deal_stages
    WebMock.stub_request(:get, "#{base_url}/api/3/dealStages").with(
      body: {},
      headers: default_headers
    ).to_return(
      status: 200,
      body: deal_stages_response
    )
  end

  def create_deal
    WebMock.stub_request(:post, "#{base_url}/api/3/deals").with(
      headers: default_headers
    ).to_return(
      status: 200,
      body: {}.to_json
    )
  end

  def create_update_contact
    WebMock.stub_request(:post, "#{base_url}/api/3/contact/sync").with(
      headers: default_headers
    ).to_return(
      status: 200,
      body: create_update_contact_response
    )
  end

  private

  def default_headers
    {
      'Content-Type': 'application/json',
      'Api-Token': ENV['ACTIVE_CAMPAING_API_KEY']
    }
  end

  def contact_fields_response
    {
      fields: [
        {
          id: '1',
          title: 'Credits'
        },
        {
          id: '2',
          title: 'Subscription Credits'
        }
      ]
    }.to_json
  end

  def deal_fields_response
    {
      dealCustomFieldMeta: [
        {
          id: '1',
          fieldLabel: 'Order Price'
        }
      ]
    }.to_json
  end

  def deal_stages_response
    {
      dealStages: [
        {
          id: '1',
          title: 'Account Confirmation'
        }
      ]
    }.to_json
  end

  def create_update_contact_response
    {
      contact: {
        id: '1'
      }
    }.to_json
  end
end

# frozen_string_literal: true

class ActiveCampaignMocker
  attr_reader :base_url, :options, :pipeline_id

  def initialize(pipeline_name: ActiveCampaign::Deal::Pipeline::EMAILS)
    @pipeline_id = deal_pipelines_map[pipeline_name]
    @base_url = ENV['ACTIVE_CAMPAING_API_URL']
  end

  def mock
    contact_fields
    deal_pipelines
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

  def deal_pipelines
    WebMock.stub_request(:get, "#{base_url}/api/3/dealGroups").with(
      body: {},
      headers: default_headers
    ).to_return(
      status: 200,
      body: deal_pipelines_response
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
    url =
      "#{base_url}/api/3/dealStages?filters[d_groupid]=#{pipeline_id}"
    WebMock.stub_request(:get, url).with(
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

  def deal_pipelines_map
    @deal_pipelines_map ||=
      JSON.parse(deal_pipelines_response)['dealGroups'].map { |field|
        [field['title'], field['id']]
      }.to_h
  end

  def deal_pipelines_response
    {
      dealGroups: [
        {
          id: '1',
          title: 'Emails'
        },
        {
          id: '2',
          title: 'Crosscourt Membership Funnel'
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

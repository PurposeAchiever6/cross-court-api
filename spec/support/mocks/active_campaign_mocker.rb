# frozen_string_literal: true

class ActiveCampaignMocker
  attr_reader :base_url, :options, :pipeline_id

  def initialize(pipeline_name: ::ActiveCampaign::Deal::Pipeline::EMAILS)
    @pipeline_id = deal_pipelines_map[pipeline_name]
    @base_url = "#{ENV['ACTIVE_CAMPAING_API_URL']}/api/3"
  end

  def mock
    contact_fields
    deal_pipelines
    deal_fields
    deal_stages
    create_deal
    create_update_contact
    add_contact_to_list
    lists('Crosscourt Master List')
  end

  def add_contact_to_list
    mock_request(
      url_path: '/contactLists',
      method: :post
    )
  end

  def lists(name = nil)
    url = '/lists?limit=100'
    url += "&filters[name]=#{name}" if name.present?

    mock_request(
      url_path: url,
      method: :get,
      response_body: lists_response
    )
  end

  def contact_fields
    mock_request(
      url_path: '/fields?limit=100',
      method: :get,
      response_body: contact_fields_response
    )
  end

  def deal_pipelines
    mock_request(
      url_path: '/dealGroups?limit=100',
      method: :get,
      response_body: deal_pipelines_response
    )
  end

  def deal_fields
    mock_request(
      url_path: '/dealCustomFieldMeta?limit=100',
      method: :get,
      response_body: deal_fields_response
    )
  end

  def deal_stages
    mock_request(
      url_path: "/dealStages?filters[d_groupid]=#{pipeline_id}&limit=100",
      method: :get,
      response_body: deal_stages_response
    )
  end

  def create_deal
    mock_request(
      url_path: '/deals',
      method: :post
    )
  end

  def create_update_contact
    mock_request(
      url_path: '/contact/sync',
      method: :post,
      response_body: create_update_contact_response
    )
  end

  private

  def mock_request(url_path:, method:, response_body: {}.to_json, status: 200)
    WebMock.stub_request(method, "#{base_url}#{url_path}").with(
      headers: default_headers
    ).to_return(
      status: status,
      body: response_body,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

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

  def lists_response
    {
      lists: [
        {
          name: 'Crosscourt Master List',
          id: 1
        }
      ]
    }.to_json
  end
end

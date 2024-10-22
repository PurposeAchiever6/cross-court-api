class ActiveCampaignService
  include HTTParty
  base_uri "#{ENV.fetch('ACTIVE_CAMPAING_API_URL', nil)}/api/3"

  attr_reader :mapped_contact_fields, :mapped_deal_fields, :mapped_deal_stages, :pipeline_id,
              :mapped_deal_pipelines

  CONTACT_ATTRS = %w[
    email first_name last_name phone_number credits subscription_credits birthday
  ].freeze

  def initialize(pipeline_name: ::ActiveCampaign::Deal::Pipeline::EMAILS)
    @pipeline_id = deal_pipelines_map[pipeline_name]
    @mapped_contact_fields = contact_fields_map
    @mapped_deal_fields = deal_fields_map
    @mapped_deal_stages = deal_stages_map
    @mapped_deal_pipelines = deal_pipelines_map
  end

  def create_update_contact(user)
    payload = contact_payload(user)
    response = execute_request(:post, '/contact/sync', payload)

    if user.id && !user.active_campaign_id
      active_campaign_id = response['contact']['id'].to_i
      user.update!(active_campaign_id:)
    end

    response
  end

  def contact_fields
    execute_request(:get, '/fields?limit=100')
  end

  def deal_pipelines
    execute_request(:get, '/dealGroups?limit=100')
  end

  def deal_fields
    execute_request(:get, '/dealCustomFieldMeta?limit=100')
  end

  def deal_stages
    execute_request(:get, "/dealStages?filters[d_groupid]=#{pipeline_id}&limit=100")
  end

  def tags
    execute_request(:get, '/tags?limit=100')
  end

  def lists(name = nil)
    url = '/lists?limit=100'
    url += "&filters[name]=#{name}" if name.present?

    execute_request(:get, url)
  end

  def create_deal(event, user, args = {})
    payload = deal_payload(event, user, args)
    execute_request(:post, '/deals', payload)
  end

  def add_contact_to_list(list_name, active_campaign_id)
    payload = add_contact_to_list_payload(list_name, active_campaign_id)
    execute_request(:post, '/contactLists', payload)
  end

  def add_tag_to_contact(tag_name, active_campaign_id)
    payload = add_tag_to_contact_payload(tag_name, active_campaign_id)
    execute_request(:post, '/contactTags', payload)
  end

  private

  def execute_request(method, url, body = nil)
    log_info("ActiveCampaign request: #{method} #{url} - #{body}")

    response = self.class.send(
      method,
      url,
      body: body.present? ? body.to_json : body,
      headers:
    )

    response_code = response.code
    parsed_response = response.parsed_response

    log_info("ActiveCampaign response: #{response_code} - #{parsed_response}")

    raise ActiveCampaignException, parsed_response unless response.success?

    parsed_response
  end

  def headers
    @headers ||=
      {
        'Content-Type': 'application/json',
        'Api-Token': ENV.fetch('ACTIVE_CAMPAING_API_KEY', nil)
      }
  end

  def logger
    @logger ||= Rails.logger
  end

  def log_info(info)
    logger.info { info }
  end

  def contact_fields_map
    @contact_fields_map ||=
      contact_fields['fields'].to_h { |field| [field['title'], field['id']] }
  end

  def deal_fields_map
    @deal_fields_map ||=
      deal_fields['dealCustomFieldMeta'].to_h { |field| [field['fieldLabel'], field['id']] }
  end

  def deal_stages_map
    @deal_stages_map ||=
      deal_stages['dealStages'].to_h { |field| [field['title'], field['id']] }
  end

  def deal_pipelines_map
    @deal_pipelines_map ||=
      deal_pipelines['dealGroups'].to_h { |field| [field['title'], field['id']] }
  end

  def tags_map
    @tags_map ||=
      tags['tags'].to_h { |field| [field['tag'], field['id']] }
  end

  def contact_payload(user)
    birthday = user.birthday
    guest = user.new_record?

    {
      contact: {
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        phone: user.phone_number,
        field_values: [
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::CREDITS],
            value: user.credits || 0
          },
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::SUBSCRIPTION_CREDITS],
            value: user.unlimited_credits? ? 'Unlimited' : user.subscription_credits || 0
          },
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::BIRTHDAY],
            value: birthday ? birthday.strftime('%Y-%m-%d') : ''
          },
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::GUEST],
            value: guest.to_s
          },
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::UTM_SOURCE],
            value: user.utm_source || 'web'
          }
        ]
      }
    }.compact.deep_transform_keys { |key| key.to_s.camelcase(:lower) }
  end

  def add_contact_to_list_payload(list_name, active_campaign_id)
    list_id = lists(list_name)['lists'].first['id']

    {
      contact_list: {
        list: list_id,
        contact: active_campaign_id,
        status: 1 # subscribed status
      }
    }.compact.deep_transform_keys { |key| key.to_s.camelcase(:lower) }
  end

  def add_tag_to_contact_payload(tag_name, active_campaign_id)
    tag_id = tags_map[tag_name]

    {
      contact_tag: {
        contact: active_campaign_id,
        tag: tag_id
      }
    }.compact.deep_transform_keys { |key| key.to_s.camelcase(:lower) }
  end

  def deal_payload(event, user, args)
    {
      deal: {
        title: user.full_name.presence || user.email,
        contact: user.active_campaign_id,
        currency: 'usd',
        status: 0,
        value: 0,
        owner: 1,
        stage: mapped_deal_stages[event],
        fields: custom_deal_fields(event, args)
      }.compact
    }
  end

  def custom_deal_fields(event_name, args)
    front_end_url = ENV.fetch('FRONTENT_URL', nil)

    fields =
      case event_name
      when ::ActiveCampaign::Deal::Event::PURCHASE_PLACED
        payment = Payment.find(args[:payment_id])
        amount = payment.amount
        discount = payment.discount
        final_price = amount - discount

        [
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::ORDER_PRICE],
            fieldValue: format('%<amount>.2f', amount:)
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::ORDER_DISCOUNT],
            fieldValue: format('%<discount>.2f', discount:)
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::ORDER_FINAL_PRICE],
            fieldValue: format('%<final_price>.2f', final_price:)
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::APPLY_DISCOUNT],
            fieldValue: discount.positive?.to_s
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::PURCHASE_NAME],
            fieldValue: payment.description
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::RECURRING],
            fieldValue: payment.chargeable&.recurring?&.to_s || 'true'
          }
        ]
      when ::ActiveCampaign::Deal::Event::CANCELLED_MEMBERSHIP
        [
          {
            customFieldId: mapped_deal_fields[
              ::ActiveCampaign::Deal::Field::CANCELLED_MEMBERSHIP_NAME
            ],
            fieldValue: args[:cancelled_membership_name]
          }
        ]
      when ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
           ::ActiveCampaign::Deal::Event::SESSION_REMINDER_6_HOURS,
           ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
           ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_IN_TIME,
           ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_OUT_OF_TIME

        user_session =
          if args[:user_session_id]
            UserSession.find(args[:user_session_id])
          else
            args[:user_session]
          end

        session_id = user_session.session_id
        formatted_date = user_session.date.strftime(Session::MONTH_NAME_FORMAT)
        location = user_session.location
        unlimited_credits = args[:unlimited_credits] ? args[:unlimited_credits].to_s : ''

        [
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::FREE_SESSION],
            fieldValue: user_session.is_free_session.to_s
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::SESSION_DATE],
            fieldValue: formatted_date
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::SESSION_TIME],
            fieldValue: user_session.time.strftime(Session::TIME_FORMAT).upcase
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::CONFIRMATION_URL],
            fieldValue: "#{front_end_url}/session/#{session_id}?date=#{formatted_date}"
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::SESSION_LOCATION_NAME],
            fieldValue: location.name
          },
          {
            customFieldId: mapped_deal_fields[
              ::ActiveCampaign::Deal::Field::SESSION_LOCATION_ADDRESS
            ],
            fieldValue: location.full_address
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::CANCELLATION_PERIOD],
            fieldValue: ENV.fetch('CANCELLATION_PERIOD', nil)
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::AMOUNT_CHARGED],
            fieldValue: args[:amount_charged].to_s || ''
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::UNLIMITED_CREDITS],
            fieldValue: unlimited_credits
          }
        ]
      when ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS
        referred = User.find(args[:referred_id])

        [
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::REFERRED_FULL_NAME],
            fieldValue: referred.full_name
          }
        ]
      when ::ActiveCampaign::Deal::Event::PROMO_CODE_REFERRAL_SUCCESS
        referred = User.find(args[:referred_id])

        [
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::REFERRED_FULL_NAME],
            fieldValue: referred.full_name.titleize
          },
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::CC_CASH_AWARDED],
            fieldValue: format('%<cc_cash>.2f', cc_cash: args[:cc_cash_awarded])
          }
        ]
      when ::ActiveCampaign::Deal::Event::STARTED_CHECKOUT
        args.map do |arg|
          {
            customFieldId: mapped_deal_fields[arg[:name]],
            fieldValue: arg[:value]
          }
        end
      when ::ActiveCampaign::Deal::Event::NEW_MEMBER
        [
          {
            customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::SUBSCRIPTION_NAME],
            fieldValue: args[:subscription_name]
          }
        ]
      else
        []
      end

    fields << {
      customFieldId: mapped_deal_fields[::ActiveCampaign::Deal::Field::FRONT_END_URL],
      fieldValue: front_end_url
    }

    fields
  end
end

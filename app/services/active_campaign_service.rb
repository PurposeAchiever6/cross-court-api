class ActiveCampaignService
  attr_reader :mapped_contact_fields, :mapped_deal_fields, :mapped_deal_stages

  CONTACT_ATTRS = %w[email first_name last_name phone_number credits subscription_credits birthday].freeze

  def initialize
    @mapped_contact_fields = contact_fields_map
    @mapped_deal_fields = deal_fields_map
    @mapped_deal_stages = deal_stages_map
  end

  def create_update_contact(user)
    payload = contact_payload(user)
    response = ActiveCampaign.post('/contact/sync', payload: payload)

    if user.id && !user.active_campaign_id
      active_campaign_id = response['contact']['id'].to_i
      user.update!(active_campaign_id: active_campaign_id)
    end

    response
  rescue StandardError => e
    logger.error { "Error when creating/updating contact. #{e.class}: #{e.message}. Payload: #{payload}" }
    raise e
  end

  def contact_fields
    ActiveCampaign.get('/fields')
  end

  def deal_fields
    ActiveCampaign.get('/dealCustomFieldMeta')
  end

  def deal_stages
    ActiveCampaign.get("/dealStages?filters[d_groupid]=#{ENV['ACTIVE_CAMPAING_EMAILS_PIPELINE_ID']}")
  end

  def create_deal(event, user, args = [])
    payload = deal_payload(event, user, args)
    ActiveCampaign.post('/deals', payload: payload)
  rescue StandardError => e
    logger.error { "Error when creating deal. #{e.class}: #{e.message}. Event: #{event}, payload: #{payload}" }
    raise e
  end

  private

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def contact_fields_map
    @contact_fields_map ||=
      contact_fields['fields'].map { |field| [field['title'], field['id']] }.to_h
  end

  def deal_fields_map
    @deal_fields_map ||=
      deal_fields['dealCustomFieldMeta'].map { |field| [field['fieldLabel'], field['id']] }.to_h
  end

  def deal_stages_map
    @deal_stages_map ||=
      deal_stages['dealStages'].map { |field| [field['title'], field['id']] }.to_h
  end

  def contact_payload(user)
    {
      contact: {
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        phone: user.phone_number,
        field_values: [
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::CREDITS],
            value: user.credits
          },
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::SUBSCRIPTION_CREDITS],
            value: user.unlimited_credits? ? 'Unlimited' : user.subscription_credits
          },
          {
            field: mapped_contact_fields[::ActiveCampaign::Contact::Field::BIRTHDAY],
            value: user.birthday.strftime('%Y-%m-%d')
          }
        ]
      }
    }.compact.deep_transform_keys { |key| key.to_s.camelcase(:lower) }
  end

  def deal_payload(event, user, args)
    {
      deal: {
        title: user.full_name || user.email,
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
    front_end_url = ENV['FRONTENT_URL']

    fields =
      case event_name
      when ::ActiveCampaign::Deal::Event::PURCHASE_PLACED
        purchase = Purchase.find(args[:purchase_id])
        price = purchase.price
        discount = purchase.discount
        final_price = price - discount

        [
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::ORDER_PRICE],
            fieldValue: format('%.2f', price)
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::ORDER_DISCOUNT],
            fieldValue: format('%.2f', discount)
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::ORDER_FINAL_PRICE],
            fieldValue: format('%.2f', final_price)
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::APPLY_DISCOUNT],
            fieldValue: discount.positive?.to_s
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::PURCHASE_NAME],
            fieldValue: purchase.product_name
          }
        ]
      when ::ActiveCampaign::Deal::Event::CANCELLED_MEMBERSHIP
        [
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::CANCELLED_MEMBERSHIP_NAME],
            fieldValue: args[:cancelled_membership_name]
          }
        ]
      when ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
           ::ActiveCampaign::Deal::Event::SESSION_REMINDER_6_HOURS,
           ::ActiveCampaign::Deal::Event::SESSION_REMINDER_8_HOURS,
           ::ActiveCampaign::Deal::Event::SESSION_REMINDER_24_HOURS,
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
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::FREE_SESSION],
            fieldValue: user_session.is_free_session.to_s
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::SESSION_DATE],
            fieldValue: formatted_date
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::SESSION_TIME],
            fieldValue: user_session.time.strftime(Session::TIME_FORMAT).upcase
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::CONFIRMATION_URL],
            fieldValue: "#{front_end_url}/session/#{session_id}?date=#{formatted_date}"
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::SESSION_LOCATION_NAME],
            fieldValue: location.name
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::SESSION_LOCATION_ADDRESS],
            fieldValue: location.full_address
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::CANCELLATION_PERIOD],
            fieldValue: ENV['CANCELLATION_PERIOD']
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::AMOUNT_CHARGED],
            fieldValue: args[:amount_charged].to_s || ''
          },
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::UNLIMITED_CREDITS],
            fieldValue: unlimited_credits
          }
        ]
      when ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS
        referred = User.find(args[:referred_id])

        [
          {
            customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::REFERRED_FULL_NAME],
            fieldValue: referred.full_name
          }
        ]
      when ::ActiveCampaign::Deal::Event::STARTED_CHECKOUT
        args.map do |arg|
          {
            customFieldId: mapped_deal_fields[arg[:name]],
            fieldValue: arg[:value]
          }
        end
      else
        []
      end

    fields << {
      customFieldId: mapped_deal_fields[ActiveCampaign::Deal::Field::FRONT_END_URL],
      fieldValue: front_end_url
    }

    fields
  end
end

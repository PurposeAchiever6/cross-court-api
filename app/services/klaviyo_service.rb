require 'rack/klaviyo'

class KlaviyoService
  attr_reader :client

  def initialize
    @client = Klaviyo::Client.new(ENV['KLAVIYO_API_KEY'])
  end

  def event(event_name, user, args = {})
    params = merge_args(general_event_attributes(user), specific_event_attributes(event_name, args))
    client.track(event_name, params)
  end

  private

  def merge_args(general_args, specific_args)
    general_args.merge(specific_args) do |_, first_values, second_values|
      first_values.merge(second_values)
    end
  end

  def general_event_attributes(user)
    user_email = user.email
    {
      email: user_email,
      customer_properties: {
        email: user_email,
        first_name: user.first_name,
        last_name: user.last_name,
        phone_number: user.phone_number,
        credits: user.credits,
        upcoming_sessions: user.user_sessions.future.not_canceled.size
      }
    }
  end

  def specific_event_attributes(event_name, args)
    front_end_url = ENV['FRONTENT_URL']

    properties =
      case event_name
      when Event::PURCHASE_PLACED
        purchase = args[:purchase]
        price = purchase.price
        discount = purchase.discount
        final_price = price - discount

        {
          order_price: format('%.2f', price),
          order_discount: format('%.2f', discount),
          order_final_price: format('%.2f', final_price),
          apply_discount: discount.positive?,
          purchase_name: purchase.product_name
        }
      when Event::SESSION_BOOKED, Event::SESSION_REMINDER_24_HOURS, Event::SESSION_REMINDER_8_HOURS,
           Event::SESSION_REMINDER_6_HOURS, Event::SESSION_CONFIRMATION,
           Event::SESSION_CANCELED_IN_TIME, Event::SESSION_CANCELED_OUT_OF_TIME

        extra_params = args[:extra_params] || {}
        user_session = args[:user_session]
        session_id = user_session.session_id
        formatted_date = user_session.date.strftime(Session::MONTH_NAME_FORMAT)
        location = user_session.location

        {
          free_session: user_session.is_free_session,
          session_date: formatted_date,
          session_time: user_session.time.strftime(Session::TIME_FORMAT).upcase,
          confirmation_url: "#{front_end_url}/session/#{session_id}?date=#{formatted_date}",
          session_location_name: location.name,
          session_location_address: location.full_address
        }.merge(extra_params)
      when Event::REFERRAL_SUCCESS
        referred = args[:referred]
        { referred_first_name: referred.first_name, referred_last_name: referred.last_name }
      else
        args
      end

    properties[:front_end_url] = front_end_url

    { properties: properties }
  end
end

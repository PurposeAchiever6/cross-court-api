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
        first_name: user.name,
        phone_number: user.phone_number,
        credits: user.credits,
        upcoming_sessions: user.user_sessions.future.not_canceled.count
      }
    }
  end

  def specific_event_attributes(event_name, args)
    params = case event_name
             when Event::PURCHASE_PLACED
               { order_price: args[:purchase].price.to_i }
             when Event::SESSION_BOOKED, Event::SESSION_REMINDER, Event::SESSION_ULTIMATUM, Event::SESSION_FORFEITED,
                  Event::SESSION_CONFIRMATION
               user_session = args[:user_session]
               session_id = user_session.session_id
               formatted_date = user_session.date.strftime(Session::DATE_FORMAT)
               {
                 session_date: formatted_date,
                 session_time: user_session.time.strftime(Session::TIME_FORMAT),
                 confirmation_url: "#{ENV['FRONTENT_URL']}/session/#{session_id}?date=#{formatted_date}"
               }
             else
               {}
             end
    { customer_properties: params }
  end
end

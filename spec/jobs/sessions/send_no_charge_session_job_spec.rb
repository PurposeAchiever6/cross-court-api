require 'rails_helper'

describe Sessions::SendNoChargeSessionJob do
  describe '#perform' do
    let!(:user) { create(:user) }
    let!(:location) { create(:location) }
    let!(:session) { create(:session, :daily, time: session_time, location:) }
    let!(:user_subscription) { create(:subscription, user:, product:) }
    let!(:product) { create(:product, no_booking_charge_feature: free_charge) }

    let(:current_time) do
      Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)).change(min: 0)
    end

    let(:session_time) { current_time + product.no_booking_charge_feature_hours.hours }
    let(:date) { current_time.to_date }
    let(:free_charge) { true }

    subject { Sessions::SendNoChargeSessionJob.perform_now }

    it 'sends no charge session email' do
      expect { subject }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with(
        'SessionMailer',
        'no_charge_session',
        anything,
        {
          params: {
            session_id: session.id,
            user_id: user.id,
            date:
          },
          args: []
        }
      )
    end

    context 'when session minutes time is not the same as current time' do
      let(:session_time) do
        current_time + product.no_booking_charge_feature_hours.hours + 38.minutes
      end

      it 'sends no charge session email' do
        expect { subject }.to have_enqueued_job(
          ActionMailer::MailDeliveryJob
        ).with('SessionMailer', 'no_charge_session', anything, anything)
      end
    end

    context 'when session hours times is not in cancellation period hours' do
      let(:session_time) do
        [
          current_time + product.no_booking_charge_feature_hours.hours + 1.hour,
          current_time + product.no_booking_charge_feature_hours.hours - 1.hour
        ].sample
      end

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when there are already more than 11 reservations for that session' do
      let!(:reservations) { create_list(:user_session, 12, session:, date:) }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end

    context 'when user product does not allow to book with no charge' do
      let!(:free_charge) { false }

      it { expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob) }
    end
  end
end
